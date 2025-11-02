#!/bin/bash

# Script to upgrade GitLab version in manifest.toml
# Usage: ./upgrade-versions.sh <version> [--add-only]
# Example: ./upgrade-versions.sh 18.6.0
# Example: ./upgrade-versions.sh 18.4.0 --add-only  (add old version without updating latest)

set -e

# Function to compare versions (returns 0 if v1 > v2, 1 otherwise)
version_gt() {
    local v1=$1
    local v2=$2

    # Use sort -V (version sort) to compare
    if [ "$(printf '%s\n%s\n' "$v1" "$v2" | sort -V | tail -n1)" = "$v1" ] && [ "$v1" != "$v2" ]; then
        return 0
    else
        return 1
    fi
}

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

    local sha256=$(curl -s "$url" | sed -n '/SHA256$/,/<\/tr>$/{ /SHA256$/d; /<\/tr>$/d; p; }' | cut -d$'\n' -f3 | xargs)

    # Return empty string if not found (for optional versions like trixie on older releases)
    echo "$sha256"
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
            echo "NOT AVAILABLE (skipping $debian_version for this version)"
        else
            echo "${sha256_map[$key]}"
        fi
    done
done

echo ""
echo "Updating manifest.toml..."
echo ""

if [ "$add_only" = false ]; then
    # Update version
    sed -i "s/^version = \"[0-9.]*~ynh[0-9]*\"/version = \"${version}~ynh1\"/" "$manifest_file"

    # Update all latest_* sections for each debian version
    for debian_version in "${debian_versions[@]}"; do
        # Skip if SHA256 not available (e.g., trixie for older versions)
        if [ -z "${sha256_map[${debian_version}_amd64]}" ]; then
            continue
        fi

        # Add missing latest_* section if it doesn't exist
        if ! grep -q "\[resources\.sources\.latest_${debian_version}\]" "$manifest_file"; then
            # Find where to insert - after the last latest_* section but before system_user or versioned sources
            last_latest_line=$(grep -n "\[resources\.sources\.latest_" "$manifest_file" | tail -n1 | cut -d: -f1)
            if [ -n "$last_latest_line" ]; then
                # Find empty line or next section after last latest_* to get the end of that section
                insert_line=$(tail -n +$((last_latest_line + 1)) "$manifest_file" | grep -n "^$" | head -n1 | cut -d: -f1)
                if [ -n "$insert_line" ]; then
                    insert_line=$((last_latest_line + insert_line))
                else
                    # If no empty line found, just add after 5 lines (approximate section length)
                    insert_line=$((last_latest_line + 5))
                fi

                # Insert debian version section
                {
                    head -n "$insert_line" "$manifest_file"
                    echo "        [resources.sources.latest_${debian_version}]"
                    echo "            extract = false"
                    echo "            rename = \"gitlab-ce.deb\""
                    for arch in "${architectures[@]}"; do
                        echo "            ${arch}.url = \"https://packages.gitlab.com/gitlab/gitlab-ce/packages/debian/${debian_version}/gitlab-ce_${version}-ce.0_${arch}.deb/download.deb\""
                        echo "            ${arch}.sha256 = \"${sha256_map[${debian_version}_${arch}]}\""
                    done
                    echo ""
                    tail -n +$((insert_line + 1)) "$manifest_file"
                } > "${manifest_file}.tmp"
                mv "${manifest_file}.tmp" "$manifest_file"
            fi
        fi

        # Update URLs and SHA256s for this debian version
        for arch in "${architectures[@]}"; do
            sed -i "/\[resources\.sources\.latest_${debian_version}\]/,/\[resources\.sources\./ {
                s|${arch}\.url = \"https://packages.gitlab.com/gitlab/gitlab-ce/packages/debian/${debian_version}/gitlab-ce_[^\"]*\"|${arch}.url = \"https://packages.gitlab.com/gitlab/gitlab-ce/packages/debian/${debian_version}/gitlab-ce_${version}-ce.0_${arch}.deb/download.deb\"|
                s|${arch}\.sha256 = \"[^\"]*\"|${arch}.sha256 = \"${sha256_map[${debian_version}_${arch}]}\"|
            }" "$manifest_file"
        done
    done
fi

# Add new versioned sources only if --add-only is used
if [ "$add_only" = true ]; then
    # Check if this version already exists (any debian version)
    if ! grep -q "\\[resources.sources.${version_id}_" "$manifest_file"; then
        # Find where to insert based on version comparison
        # Parse all existing versions and find the right position
        insert_line=""

        # Get all existing GitLab version comments with their line numbers
        existing_versions=$(grep -n "^\s*# GitLab [0-9]" "$manifest_file" || true)

        if [ -n "$existing_versions" ]; then
            # Find the first version that is less than our new version
            while IFS=: read -r line_num version_line; do
                existing_ver=$(echo "$version_line" | grep -oP "GitLab \K[0-9.]+")

                # Compare versions: if new version is greater, insert before this one
                if version_gt "$version" "$existing_ver"; then
                    insert_line=$((line_num - 1))
                    break
                fi
            done <<< "$existing_versions"
        fi

        # If no position found yet, insert after the last latest_* section
        if [ -z "$insert_line" ]; then
            # Find the last latest_* section and insert right after it (6 lines: header + 5 properties)
            last_latest_line=$(grep -n "^\s*\[resources\.sources\.latest_" "$manifest_file" | tail -n1 | cut -d: -f1)
            if [ -n "$last_latest_line" ]; then
                insert_line=$((last_latest_line + 6))
            fi
        fi

        if [ -n "$insert_line" ]; then
            # Create temp file with new content
            {
                head -n "$insert_line" "$manifest_file"

                # Add an empty line before the comment if this is the first version
                # (when inserting after latest_*, there's no empty line yet)
                if [ -z "$existing_versions" ]; then
                    echo ""
                fi

                # Add comment
                echo "        # GitLab $version"

                # Add a section for each debian version that has SHA256 values
                for debian_version in "${debian_versions[@]}"; do
                    # Skip if SHA256 not available
                    if [ -z "${sha256_map[${debian_version}_amd64]}" ]; then
                        continue
                    fi

                    echo "        [resources.sources.${version_id}_${debian_version}]"
                    echo "            prefetch = false"
                    echo "            extract = false"
                    echo "            rename = \"gitlab-ce.deb\""
                    for arch in "${architectures[@]}"; do
                        echo "            ${arch}.url = \"https://packages.gitlab.com/gitlab/gitlab-ce/packages/debian/${debian_version}/gitlab-ce_${version}-ce.0_${arch}.deb/download.deb\""
                        echo "            ${arch}.sha256 = \"${sha256_map[${debian_version}_${arch}]}\""
                    done
                    echo ""
                done

                tail -n +$((insert_line + 1)) "$manifest_file"
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
