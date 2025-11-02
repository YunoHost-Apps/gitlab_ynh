#!/bin/bash

# Script to upgrade GitLab version in manifest.toml
# Usage: ./upgrade-versions.sh <version> [--add-only]
# Example: ./upgrade-versions.sh 18.6.0
# Example: ./upgrade-versions.sh 18.4.0 --add-only  (add old version without updating latest)

set -e

if [ -z "$1" ]; then
    echo "Usage: $0 <version> [--add-only]"
    echo ""
    echo "Options:"
    echo "  <version>     GitLab version to add/update (e.g., 18.6.0)"
    echo "  --add-only    Add version sources without updating latest_* entries"
    echo ""
    echo "Examples:"
    echo "  $0 18.6.0              # Update to latest version"
    echo "  $0 18.4.0 --add-only   # Add old version for upgrade path"
    exit 1
fi

version=$1
add_only=false

if [ "$2" = "--add-only" ]; then
    add_only=true
fi
current_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
manifest_file="$current_dir/manifest.toml"

# Create version identifier for TOML section name (e.g., "18.6.0" -> "v18_5_1")
version_id="v$(echo "$version" | tr '.' '_')"

debian_versions=("bullseye" "bookworm" "trixie")
architectures=("amd64" "arm64")

if [ "$add_only" = true ]; then
    echo "========================================="
    echo "Adding GitLab version $version to sources"
    echo "(without updating latest)"
    echo "========================================="
else
    echo "========================================="
    echo "Upgrading GitLab to version $version"
    echo "========================================="
fi
echo ""

# Function to fetch SHA256 from GitLab packages website (silently)
fetch_sha256() {
    local debian_version=$1
    local architecture=$2
    local url="https://packages.gitlab.com/gitlab/gitlab-ce/packages/debian/${debian_version}/gitlab-ce_${version}-ce.0_${architecture}.deb"

    curl -s "$url" | sed -n '/SHA256$/,/<\/tr>$/{ /SHA256$/d; /<\/tr>$/d; p; }' | cut -d$'\n' -f3 | xargs
}

# Fetch all SHA256s
declare -A sha256_map

echo "Fetching SHA256 checksums..."
echo ""

for debian_version in "${debian_versions[@]}"; do
    for arch in "${architectures[@]}"; do
        echo -n "  $debian_version/$arch ... "
        key="${debian_version}_${arch}"
        sha256_map[$key]=$(fetch_sha256 "$debian_version" "$arch")

        if [ -z "${sha256_map[$key]}" ]; then
            echo "FAILED!"
            echo "ERROR: Failed to fetch SHA256 for $arch on $debian_version"
            exit 1
        fi
        echo "${sha256_map[$key]}"
    done
done

echo ""
echo "Updating manifest.toml..."
echo ""

if [ "$add_only" = false ]; then
    # 1. Update version
    sed -i "s/^version = \"[0-9.]*~ynh[0-9]*\"/version = \"${version}~ynh1\"/" "$manifest_file"

    # 2. Update latest_bookworm amd64 URL
    sed -i "/\[resources\.sources\.latest_bookworm\]/,/\[resources\.sources\./ {
        s|amd64\.url = \"https://packages.gitlab.com/gitlab/gitlab-ce/packages/debian/bookworm/gitlab-ce_[^\"]*\"|amd64.url = \"https://packages.gitlab.com/gitlab/gitlab-ce/packages/debian/bookworm/gitlab-ce_${version}-ce.0_amd64.deb/download.deb\"|
    }" "$manifest_file"

    # 3. Update latest_bookworm amd64 SHA256
    sed -i "/\[resources\.sources\.latest_bookworm\]/,/\[resources\.sources\./ {
        s|amd64\.sha256 = \"[^\"]*\"|amd64.sha256 = \"${sha256_map[bookworm_amd64]}\"|
    }" "$manifest_file"

    # 4. Update latest_bookworm arm64 URL
    sed -i "/\[resources\.sources\.latest_bookworm\]/,/\[resources\.sources\./ {
        s|arm64\.url = \"https://packages.gitlab.com/gitlab/gitlab-ce/packages/debian/bookworm/gitlab-ce_[^\"]*\"|arm64.url = \"https://packages.gitlab.com/gitlab/gitlab-ce/packages/debian/bookworm/gitlab-ce_${version}-ce.0_arm64.deb/download.deb\"|
    }" "$manifest_file"

    # 5. Update latest_bookworm arm64 SHA256
    sed -i "/\[resources\.sources\.latest_bookworm\]/,/\[resources\.sources\./ {
        s|arm64\.sha256 = \"[^\"]*\"|arm64.sha256 = \"${sha256_map[bookworm_arm64]}\"|
    }" "$manifest_file"

    # 6. Update latest_trixie amd64 URL
    sed -i "/\[resources\.sources\.latest_trixie\]/,/\[resources\.sources\./ {
        s|amd64\.url = \"https://packages.gitlab.com/gitlab/gitlab-ce/packages/debian/trixie/gitlab-ce_[^\"]*\"|amd64.url = \"https://packages.gitlab.com/gitlab/gitlab-ce/packages/debian/trixie/gitlab-ce_${version}-ce.0_amd64.deb/download.deb\"|
    }" "$manifest_file"

    # 7. Update latest_trixie amd64 SHA256
    sed -i "/\[resources\.sources\.latest_trixie\]/,/\[resources\.sources\./ {
        s|amd64\.sha256 = \"[^\"]*\"|amd64.sha256 = \"${sha256_map[trixie_amd64]}\"|
    }" "$manifest_file"

    # 8. Update latest_trixie arm64 URL
    sed -i "/\[resources\.sources\.latest_trixie\]/,/\[resources\.sources\./ {
        s|arm64\.url = \"https://packages.gitlab.com/gitlab/gitlab-ce/packages/debian/trixie/gitlab-ce_[^\"]*\"|arm64.url = \"https://packages.gitlab.com/gitlab/gitlab-ce/packages/debian/trixie/gitlab-ce_${version}-ce.0_arm64.deb/download.deb\"|
    }" "$manifest_file"

    # 9. Update latest_trixie arm64 SHA256
    sed -i "/\[resources\.sources\.latest_trixie\]/,/\[resources\.sources\./ {
        s|arm64\.sha256 = \"[^\"]*\"|arm64.sha256 = \"${sha256_map[trixie_arm64]}\"|
    }" "$manifest_file"

    # 10. Update latest_bullseye amd64 URL
    sed -i "/\[resources\.sources\.latest_bullseye\]/,/\[resources\.sources\./ {
        s|amd64\.url = \"https://packages.gitlab.com/gitlab/gitlab-ce/packages/debian/bullseye/gitlab-ce_[^\"]*\"|amd64.url = \"https://packages.gitlab.com/gitlab/gitlab-ce/packages/debian/bullseye/gitlab-ce_${version}-ce.0_amd64.deb/download.deb\"|
    }" "$manifest_file"

    # 11. Update latest_bullseye amd64 SHA256
    sed -i "/\[resources\.sources\.latest_bullseye\]/,/\[resources\.sources\./ {
        s|amd64\.sha256 = \"[^\"]*\"|amd64.sha256 = \"${sha256_map[bullseye_amd64]}\"|
    }" "$manifest_file"

    # 12. Update latest_bullseye arm64 URL
    sed -i "/\[resources\.sources\.latest_bullseye\]/,/\[resources\.sources\./ {
        s|arm64\.url = \"https://packages.gitlab.com/gitlab/gitlab-ce/packages/debian/bullseye/gitlab-ce_[^\"]*\"|arm64.url = \"https://packages.gitlab.com/gitlab/gitlab-ce/packages/debian/bullseye/gitlab-ce_${version}-ce.0_arm64.deb/download.deb\"|
    }" "$manifest_file"

    # 13. Update latest_bullseye arm64 SHA256
    sed -i "/\[resources\.sources\.latest_bullseye\]/,/\[resources\.sources\./ {
        s|arm64\.sha256 = \"[^\"]*\"|arm64.sha256 = \"${sha256_map[bullseye_arm64]}\"|
    }" "$manifest_file"
fi

# 14. Add new versioned sources only if --add-only is used
if [ "$add_only" = true ]; then
    if ! grep -q "\\[resources.sources.${version_id}_bookworm\\]" "$manifest_file"; then
        # Find line number of [resources.system_user]
        line_num=$(grep -n "    \[resources\.system_user\]" "$manifest_file" | cut -d: -f1)

        if [ -n "$line_num" ]; then
            # Insert before this line
            insert_line=$((line_num - 1))

            # Create temp file with new content
            {
                head -n "$insert_line" "$manifest_file"
                cat <<EOF

    # GitLab $version
        [resources.sources.${version_id}_bookworm]
        extract = false
        rename = "gitlab-ce.deb"
        amd64.url = "https://packages.gitlab.com/gitlab/gitlab-ce/packages/debian/bookworm/gitlab-ce_${version}-ce.0_amd64.deb/download.deb"
        amd64.sha256 = "${sha256_map[bookworm_amd64]}"
        arm64.url = "https://packages.gitlab.com/gitlab/gitlab-ce/packages/debian/bookworm/gitlab-ce_${version}-ce.0_arm64.deb/download.deb"
        arm64.sha256 = "${sha256_map[bookworm_arm64]}"

        [resources.sources.${version_id}_trixie]
        extract = false
        rename = "gitlab-ce.deb"
        amd64.url = "https://packages.gitlab.com/gitlab/gitlab-ce/packages/debian/trixie/gitlab-ce_${version}-ce.0_amd64.deb/download.deb"
        amd64.sha256 = "${sha256_map[trixie_amd64]}"
        arm64.url = "https://packages.gitlab.com/gitlab/gitlab-ce/packages/debian/trixie/gitlab-ce_${version}-ce.0_arm64.deb/download.deb"
        arm64.sha256 = "${sha256_map[trixie_arm64]}"

        [resources.sources.${version_id}_bullseye]
        extract = false
        rename = "gitlab-ce.deb"
        amd64.url = "https://packages.gitlab.com/gitlab/gitlab-ce/packages/debian/bullseye/gitlab-ce_${version}-ce.0_amd64.deb/download.deb"
        amd64.sha256 = "${sha256_map[bullseye_amd64]}"
        arm64.url = "https://packages.gitlab.com/gitlab/gitlab-ce/packages/debian/bullseye/gitlab-ce_${version}-ce.0_arm64.deb/download.deb"
        arm64.sha256 = "${sha256_map[bullseye_arm64]}"
EOF
                tail -n +$((line_num)) "$manifest_file"
            } > "${manifest_file}.tmp"

            mv "${manifest_file}.tmp" "$manifest_file"
        fi
    fi
fi

echo "✓ manifest.toml updated"
echo ""

if [ "$add_only" = false ]; then
    echo "========================================="
    echo "Updating gitlab.rb configuration..."
    echo "========================================="
    echo ""

    # Update gitlab.rb
    conf_file="$current_dir/conf/gitlab.rb"
    url="https://gitlab.com/gitlab-org/omnibus-gitlab/-/raw/${version}+ce.0/files/gitlab-config-template/gitlab.rb.template"

    header="################################################################################
################################################################################
##                             FOR YUNOHOST USERS                             ##
################################################################################
################################################################################

# Please do not modify this file, it will be reset with the next update.
# You can create or modify the file:
# /etc/gitlab/gitlab-persistent.rb
# and add all the configuration you want.
# Options you add in gitlab-presistent.rb will overide these one,
# but you can use options and documentations in this file to know what
# is it possible to do.

################################################################################
################################################################################
"

    footer="
from_file '/etc/gitlab/gitlab-persistent.rb'"

    echo "$header" > "$conf_file"

    echo "Downloading GitLab config template from upstream..."
    if ! curl -s "$url" >> "$conf_file"; then
        echo "ERROR: Failed to download gitlab.rb template"
        exit 1
    fi

    echo "$footer" >> "$conf_file"

    # Apply YunoHost-specific modifications
    echo "Applying YunoHost-specific modifications..."

    # Change external url
    sed -i "s/external_url 'GENERATED_EXTERNAL_URL'/external_url '__GENERATED_EXTERNAL_URL__'/" "$conf_file"

    # Activate ldap
    sed -i "s/# gitlab_rails\['ldap_enabled'\] = .*/gitlab_rails['ldap_enabled'] = true/" "$conf_file"

    ldap_conf="
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
EOS"

    # Add ldap conf
    sed -i "/^# EOS/r "<(echo "$ldap_conf") "$conf_file"

    # Change ssh port
    sed -i "s/# gitlab_rails\['gitlab_shell_ssh_port'\] = 22/gitlab_rails['gitlab_shell_ssh_port'] = __SSH_PORT__/" "$conf_file"

    # Change puma settings
    sed -i "s/# puma\['port'\] = .*/puma['port'] = __PORT_PUMA__/" "$conf_file"

    # Change sidekiq settings
    sed -i "s/# sidekiq\['listen_port'\] = .*/sidekiq['listen_port'] = __PORT_SIDEKIQ__/" "$conf_file"

    # Change nginx settings
    sed -i "s/# nginx\['client_max_body_size'\] = .*/nginx['client_max_body_size'] = '__CLIENT_MAX_BODY_SIZE__'/" "$conf_file"
    sed -i "s/# nginx\['listen_port'\] = .*/nginx['listen_port'] = __PORT__/" "$conf_file"
    sed -i "s/# nginx\['listen_https'\] = .*/nginx['listen_https'] = false/" "$conf_file"

    # Change modify kernel parameters settings
    sed -i "s/# package\['modify_kernel_parameters'\] = .*/package['modify_kernel_parameters'] = __MODIFY_KERNEL_PARAMETERS__/" "$conf_file"
fi

echo ""
echo "========================================="
echo "✓ Update complete!"
echo "========================================="
echo ""
if [ "$add_only" = true ]; then
    echo "Summary:"
    echo "  - Added new source entries: ${version_id}_bookworm, ${version_id}_trixie and ${version_id}_bullseye"
    echo "  - latest_bookworm, latest_trixie and latest_bullseye were NOT modified"
    echo "  - Package version was NOT modified"
    echo ""
    echo "Please review the changes and commit if everything looks good:"
    echo "  git diff manifest.toml"
    echo "  git add manifest.toml"
    echo "  git commit -m \"Add GitLab $version sources for upgrade path\""
else
    echo "Summary:"
    echo "  - Updated latest_bookworm, latest_trixie and latest_bullseye to version $version"
    echo "  - Updated package version to ${version}~ynh1"
    echo "  - Updated conf/gitlab.rb from upstream"
    echo "  - No new versioned sources were added"
    echo ""
    echo "Please review the changes and commit if everything looks good:"
    echo "  git diff manifest.toml conf/gitlab.rb"
    echo "  git add manifest.toml conf/gitlab.rb"
    echo "  git commit -m \"Upgrade to GitLab $version\""
fi
