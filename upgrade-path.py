#!/usr/bin/env python3
"""
GitLab YunoHost upgrade path processor.

This script:
1. Fetches the upgrade path from GitLab's official tool
2. Fetches SHA256 checksums from packages.gitlab.com
3. Renders manifest.toml from the Jinja2 template

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

ARCHITECTURES = ["amd64", "arm64"]
DISTROS = ["bullseye", "bookworm", "trixie"]
EDITIONS = ["ce", "ee"]

UPGRADE_PATH_URL = "https://gitlab-com.gitlab.io/support/toolbox/upgrade-path/path.json"


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

    print("\nDone! Review changes with: git diff manifest.toml")


if __name__ == "__main__":
    main()
