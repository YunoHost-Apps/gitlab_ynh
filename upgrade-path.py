#!/usr/bin/env python3
"""
GitLab YunoHost upgrade path processor.

This script:
1. Fetches the upgrade path from GitLab's official tool
2. Fetches SHA256 checksums from packages.gitlab.com
3. Renders manifest.toml from the Jinja2 template
4. Downloads and patches gitlab.rb from upstream

Usage:
    ./upgrade-path.py <starting_version>
    ./upgrade-path.py 16.11.10
"""

import argparse
import re
import sys
import urllib.request
import json
from pathlib import Path

try:
    from jinja2 import Environment, FileSystemLoader
except ImportError:
    print("Error: jinja2 is required. Install with: pip install jinja2")
    sys.exit(1)

SCRIPT_DIR = Path(__file__).parent
TEMPLATE_FILE = "manifest.toml.j2"
OUTPUT_FILE = "manifest.toml"
GITLAB_RB_FILE = "conf/gitlab.rb"

ARCHITECTURES = ["amd64", "arm64"]
DISTROS = ["bullseye", "bookworm", "trixie"]
EDITIONS = ["ce", "ee"]

UPGRADE_PATH_URL = "https://gitlab-com.gitlab.io/support/toolbox/upgrade-path/path.json"
GITLAB_RB_TEMPLATE_URL = "https://gitlab.com/gitlab-org/omnibus-gitlab/-/raw/{version}+ce.0/files/gitlab-config-template/gitlab.rb.template"

GITLAB_RB_HEADER = """################################################################################
################################################################################
##                             FOR YUNOHOST USERS                             ##
################################################################################
################################################################################

# Please do not modify this file, it will be reset with the next update.
# You can create or modify the file:
# /etc/gitlab/gitlab-persistent.rb
# and add all the configuration you want.
# Options you add in gitlab-persistent.rb will override these one,
# but you can use options and documentations in this file to know what
# is it possible to do.

################################################################################
################################################################################
"""

GITLAB_RB_FOOTER = """
from_file '/etc/gitlab/gitlab-persistent.rb'"""

LDAP_CONFIG = """
gitlab_rails['ldap_servers'] = YAML.load <<-'EOS' # remember to close this block with 'EOS' below
  main: # 'main' is the GitLab 'provider ID' of this LDAP server
    label: 'YunoHost LDAP'
    host: 'localhost'
    port: 389
    uid: 'uid'
    encryption: 'plain' # 'start_tls' or 'simple_tls' or 'plain'
    bind_dn: 'ou=users,dc=yunohost,dc=org'
    password: ''
    active_directory: false
    allow_username_or_email_login: false
    block_auto_created_users: false
    base: 'dc=yunohost,dc=org'
    user_filter: '(&(objectClass=posixAccount)(permission=cn=gitlab.main,ou=permission,dc=yunohost,dc=org))'
    timeout: 10
    attributes: {
      username: ['uid', 'sAMAccountName'],
      name: 'cn',
      first_name: 'givenName',
      last_name: 'sn'
    }
EOS"""


class FetchError(Exception):
    """Raised when fetching a package fails."""
    pass


def fetch_sha256(edition: str, version: str, distro: str, arch: str) -> str:
    """Fetch SHA256 checksum from packages.gitlab.com.

    Raises:
        FetchError: If the package doesn't exist or SHA256 can't be found.
    """
    url = f"https://packages.gitlab.com/gitlab/gitlab-{edition}/packages/debian/{distro}/gitlab-{edition}_{version}-{edition}.0_{arch}.deb"
    print(f"  Fetching SHA256 for {edition}/{version}/{distro}/{arch}...", end=" ", flush=True)

    try:
        with urllib.request.urlopen(url, timeout=30) as response:
            content = response.read().decode('utf-8')
    except Exception as e:
        print(f"FAILED ({e})")
        raise FetchError(f"Failed to fetch {url}: {e}")

    # Parse SHA256 from HTML page
    match = re.search(r'SHA256.*?<td[^>]*>\s*([a-f0-9]{64})\s*</td>', content, re.DOTALL | re.IGNORECASE)
    if match:
        sha256 = match.group(1)
        print(f"OK ({sha256[:16]}...)")
        return sha256

    print("NOT FOUND")
    raise FetchError(f"SHA256 not found in page for {url}")


def fetch_all_sha256(version: str, distros: list = DISTROS) -> tuple[dict, list]:
    """Fetch all SHA256 checksums for a version.

    Returns:
        tuple: (sha256_dict, available_distros)
        Only returns distros where all packages are available.
    """
    result = {"ce": {}, "ee": {}}
    available_distros = []

    for distro in distros:
        distro_data = {"ce": {}, "ee": {}}
        try:
            for edition in EDITIONS:
                for arch in ARCHITECTURES:
                    sha256 = fetch_sha256(edition, version, distro, arch)
                    distro_data[edition][arch] = sha256
            # All fetches succeeded for this distro
            available_distros.append(distro)
            for edition in EDITIONS:
                result[edition][distro] = distro_data[edition]
        except FetchError:
            # Skip this distro, already printed error
            print(f"  Skipping {distro} for version {version}")

    return result, available_distros


def fetch_upgrade_path(starting_version: str) -> list:
    """Fetch upgrade path from GitLab's official tool."""
    print(f"Fetching upgrade path from {UPGRADE_PATH_URL}...")

    try:
        with urllib.request.urlopen(UPGRADE_PATH_URL, timeout=30) as response:
            content = response.read().decode('utf-8')
    except Exception as e:
        print(f"Error: Failed to fetch upgrade path data: {e}")
        sys.exit(1)

    data = json.loads(content)
    all_versions = data.get("all", [])

    if not all_versions:
        print("Error: No versions found in upgrade path data")
        sys.exit(1)

    # Find starting index
    start_idx = None
    for i, ver in enumerate(all_versions):
        if ver == starting_version:
            start_idx = i
            break
        # If exact version not found, find first version >= starting_version
        if compare_versions(ver, starting_version) >= 0 and start_idx is None:
            start_idx = i
            print(f"Version {starting_version} not found, using {ver} instead")
            break

    if start_idx is None:
        print(f"Error: No version >= {starting_version} found")
        sys.exit(1)

    return all_versions[start_idx:]


def compare_versions(v1: str, v2: str) -> int:
    """Compare two version strings. Returns -1, 0, or 1."""
    def parse(v):
        return [int(x) for x in v.split(".")]

    p1, p2 = parse(v1), parse(v2)

    for a, b in zip(p1, p2):
        if a < b:
            return -1
        if a > b:
            return 1

    return len(p1) - len(p2)


def render_manifest(latest_version: str, latest_sha256: dict, upgrade_path: list, latest_distros: list):
    """Render manifest.toml from template."""
    env = Environment(
        loader=FileSystemLoader(SCRIPT_DIR),
        keep_trailing_newline=True,
        trim_blocks=True,
        lstrip_blocks=True,
    )

    template = env.get_template(TEMPLATE_FILE)

    output = template.render(
        latest_version=latest_version,
        latest=latest_sha256,
        distros=latest_distros,
        architectures=ARCHITECTURES,
        upgrade_path=upgrade_path,
    )

    output_path = SCRIPT_DIR / OUTPUT_FILE
    output_path.write_text(output)
    print(f"\nGenerated {output_path}")


def update_gitlab_rb(version: str):
    """Download gitlab.rb template from upstream and apply YunoHost patches."""
    print(f"\nUpdating gitlab.rb from upstream ({version})...")

    url = GITLAB_RB_TEMPLATE_URL.format(version=version)
    print(f"  Downloading from {url}...")

    try:
        with urllib.request.urlopen(url, timeout=60) as response:
            content = response.read().decode('utf-8')
    except Exception as e:
        print(f"ERROR: Failed to download gitlab.rb template: {e}")
        sys.exit(1)

    print("  Applying YunoHost patches...")

    # Apply sed-like replacements
    replacements = [
        # External URL
        (r"external_url 'GENERATED_EXTERNAL_URL'",
         "external_url '__GENERATED_EXTERNAL_URL__'"),

        # LDAP
        (r"# gitlab_rails\['ldap_enabled'\] = .*",
         "gitlab_rails['ldap_enabled'] = true"),

        # SSH port
        (r"# gitlab_rails\['gitlab_shell_ssh_port'\] = 22",
         "gitlab_rails['gitlab_shell_ssh_port'] = __SSH_PORT__"),

        # Puma port
        (r"# puma\['port'\] = .*",
         "puma['port'] = __PORT_PUMA__"),

        # Sidekiq port
        (r"# sidekiq\['listen_port'\] = .*",
         "sidekiq['listen_port'] = __PORT_SIDEKIQ__"),

        # Nginx settings
        (r"# nginx\['client_max_body_size'\] = .*",
         "nginx['client_max_body_size'] = '__CLIENT_MAX_BODY_SIZE__'"),
        (r"# nginx\['listen_port'\] = .*",
         "nginx['listen_port'] = __PORT__"),
        (r"# nginx\['listen_https'\] = .*",
         "nginx['listen_https'] = false"),

        # Kernel parameters
        (r"# package\['modify_kernel_parameters'\] = .*",
         "package['modify_kernel_parameters'] = __MODIFY_KERNEL_PARAMETERS__"),

        # GitLab Pages
        (r"# pages_external_url \"http://pages\.example\.com/\"",
         'pages_external_url "https://__PAGES_URL__/"'),
        (r"# gitlab_pages\['enable'\] = false",
         "gitlab_pages['enable'] = __PAGES_ENABLE__"),
        (r"# gitlab_pages\['listen_proxy'\] = \"localhost:8090\"",
         "gitlab_pages['listen_proxy'] = \"127.0.0.1:__PORT_PAGES__\""),
        (r"# gitlab_pages\['namespace_in_path'\] = false",
         "gitlab_pages['namespace_in_path'] = true"),
        (r"# gitlab_pages\['internal_gitlab_server'\] = nil",
         "gitlab_pages['internal_gitlab_server'] = \"http://127.0.0.1:__PORT__\""),
        (r"# pages_nginx\['enable'\] = true",
         "pages_nginx['enable'] = __PAGES_ENABLE__"),
    ]

    for pattern, replacement in replacements:
        content = re.sub(pattern, replacement, content)

    # Insert LDAP config after "# EOS" line
    content = re.sub(r"(^# EOS$)", r"\1" + LDAP_CONFIG, content, count=1, flags=re.MULTILINE)

    # Add pages_nginx settings after pages_nginx['enable'] = true
    pages_nginx_config = """
pages_nginx['listen_https'] = false
pages_nginx['listen_http'] = true
pages_nginx['listen_port'] = __PORT_NGINX_PAGES__
pages_nginx['listen_addresses'] = ['127.0.0.1']"""

    content = re.sub(
        r"(pages_nginx\['enable'\] = true)",
        r"\1" + pages_nginx_config,
        content
    )

    # Write final file
    output_path = SCRIPT_DIR / GITLAB_RB_FILE
    output_path.write_text(GITLAB_RB_HEADER + content + GITLAB_RB_FOOTER)
    print(f"  Generated {output_path}")


def main():
    parser = argparse.ArgumentParser(description="Process GitLab upgrade path")
    parser.add_argument("starting_version", help="Starting version (e.g., 16.11.10)")
    parser.add_argument("--latest-only", action="store_true",
                        help="Only update latest version, skip upgrade path")
    args = parser.parse_args()

    # Fetch upgrade path
    if args.latest_only:
        versions = [args.starting_version]
    else:
        versions = fetch_upgrade_path(args.starting_version)

    print(f"\nVersions to process: {len(versions)}")
    for v in versions:
        print(f"  - {v}")
    print()

    # Latest version is the last one
    latest_version = versions[-1]

    # Fetch SHA256 for latest version
    print(f"Fetching SHA256 for latest version ({latest_version})...")
    latest_sha256, latest_distros = fetch_all_sha256(latest_version)

    if not latest_distros:
        print("Error: No packages available for latest version")
        sys.exit(1)

    # Fetch SHA256 for intermediate versions (upgrade path)
    upgrade_path_data = []
    if len(versions) > 1:
        for version in versions[:-1]:  # All except the last (latest)
            print(f"\nFetching SHA256 for upgrade path version ({version})...")
            sha256_data, available_distros = fetch_all_sha256(version)
            if available_distros:
                upgrade_path_data.append({
                    "version": version,
                    "distros": available_distros,
                    **sha256_data,
                })
            else:
                print(f"  Skipping {version} - no packages available")

    # Render template (reverse upgrade path so newest versions come first)
    render_manifest(latest_version, latest_sha256, list(reversed(upgrade_path_data)), latest_distros)

    # Update gitlab.rb from upstream
    update_gitlab_rb(latest_version)

    print("\nDone! Review changes with: git diff manifest.toml conf/gitlab.rb")


if __name__ == "__main__":
    main()
