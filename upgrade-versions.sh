#!/bin/bash

# Script to upgrade GitLab version in manifest.toml
# Usage: ./upgrade-versions.sh <version> [--edition ce|ee] [--add-only]
#
# Examples:
#   ./upgrade-versions.sh 18.6.0                    # Update both CE and EE to latest version
#   ./upgrade-versions.sh 18.6.0 --edition ce       # Update only CE
#   ./upgrade-versions.sh 18.4.0 --add-only         # Add old version for upgrade path (both editions)
#   ./upgrade-versions.sh 18.4.0 --edition ee --add-only  # Add old version for EE only

set -e

# Function to compare versions (returns 0 if v1 > v2, 1 otherwise)
version_gt() {
    local v1=$1
    local v2=$2

    if [ "$(printf '%s\n%s\n' "$v1" "$v2" | sort -V | tail -n1)" = "$v1" ] && [ "$v1" != "$v2" ]; then
        return 0
    else
        return 1
    fi
}

# Parse arguments
version=""
edition="both"  # ce, ee, or both
add_only=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --edition)
            edition="$2"
            if [[ "$edition" != "ce" && "$edition" != "ee" ]]; then
                echo "ERROR: --edition must be 'ce' or 'ee'"
                exit 1
            fi
            shift 2
            ;;
        --add-only)
            add_only=true
            shift
            ;;
        -*)
            echo "Unknown option: $1"
            exit 1
            ;;
        *)
            if [ -z "$version" ]; then
                version="$1"
            else
                echo "ERROR: Unexpected argument: $1"
                exit 1
            fi
            shift
            ;;
    esac
done

if [ -z "$version" ]; then
    echo "Usage: $0 <version> [--edition ce|ee] [--add-only]"
    echo ""
    echo "Options:"
    echo "  <version>         GitLab version to add/update (e.g., 18.6.0)"
    echo "  --edition ce|ee   Update only CE or EE (default: both)"
    echo "  --add-only        Add version sources without updating latest_* entries"
    echo ""
    echo "Examples:"
    echo "  $0 18.6.0                          # Update both CE and EE to latest"
    echo "  $0 18.6.0 --edition ce             # Update only CE"
    echo "  $0 18.4.0 --add-only               # Add upgrade path sources for both"
    echo "  $0 18.4.0 --edition ee --add-only  # Add upgrade path sources for EE only"
    exit 1
fi

current_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
manifest_file="$current_dir/manifest.toml"

# Create version identifier for TOML section name (e.g., "18.6.0" -> "v18_6_0")
version_id="v$(echo "$version" | tr '.' '_')"

debian_versions=("bullseye" "bookworm" "trixie")
architectures=("amd64" "arm64")

# Determine which editions to process
editions_to_process=()
if [ "$edition" = "both" ]; then
    editions_to_process=("ce" "ee")
else
    editions_to_process=("$edition")
fi

if [ "$add_only" = true ]; then
    echo "========================================="
    echo "Adding GitLab $version to sources"
    echo "Edition(s): ${editions_to_process[*]}"
    echo "(without updating latest)"
    echo "========================================="
else
    echo "========================================="
    echo "Upgrading GitLab to version $version"
    echo "Edition(s): ${editions_to_process[*]}"
    echo "========================================="
fi
echo ""

# Function to fetch SHA256 from GitLab packages website
fetch_sha256() {
    local ed=$1
    local debian_version=$2
    local architecture=$3
    local url="https://packages.gitlab.com/gitlab/gitlab-${ed}/packages/debian/${debian_version}/gitlab-${ed}_${version}-${ed}.0_${architecture}.deb"

    local sha256=$(curl -s "$url" | sed -n '/SHA256$/,/<\/tr>$/{ /SHA256$/d; /<\/tr>$/d; p; }' | cut -d$'\n' -f3 | xargs)
    echo "$sha256"
}

# Function to get source suffix for manifest (ee uses latest_ee_*, ce uses latest_*)
get_latest_source_suffix() {
    local ed=$1
    local debian_version=$2
    if [ "$ed" = "ee" ]; then
        echo "latest_ee_${debian_version}"
    else
        echo "latest_${debian_version}"
    fi
}

# Function to get versioned source suffix
get_versioned_source_suffix() {
    local ed=$1
    local debian_version=$2
    if [ "$ed" = "ee" ]; then
        echo "${version_id}_ee_${debian_version}"
    else
        echo "${version_id}_${debian_version}"
    fi
}

# Process each edition
for ed in "${editions_to_process[@]}"; do
    echo "Processing GitLab ${ed^^}..."
    echo ""

    # Fetch all SHA256s for this edition
    declare -A sha256_map

    echo "Fetching SHA256 checksums for ${ed^^}..."
    for debian_version in "${debian_versions[@]}"; do
        for arch in "${architectures[@]}"; do
            echo -n "  $debian_version/$arch ... "
            key="${debian_version}_${arch}"
            sha256_map[$key]=$(fetch_sha256 "$ed" "$debian_version" "$arch")

            if [ -z "${sha256_map[$key]}" ]; then
                echo "NOT AVAILABLE"
            else
                echo "${sha256_map[$key]}"
            fi
        done
    done
    echo ""

    if [ "$add_only" = false ]; then
        # Only update package version once (when processing first edition or CE)
        if [ "$ed" = "ce" ] || [ "$edition" = "ee" ]; then
            sed -i "s/^version = \"[0-9.]*~ynh[0-9]*\"/version = \"${version}~ynh1\"/" "$manifest_file"
        fi

        # Update all latest_* sections for this edition
        for debian_version in "${debian_versions[@]}"; do
            if [ -z "${sha256_map[${debian_version}_amd64]}" ]; then
                continue
            fi

            source_suffix=$(get_latest_source_suffix "$ed" "$debian_version")

            # Update URLs and SHA256s
            for arch in "${architectures[@]}"; do
                sed -i "/\[resources\.sources\.${source_suffix}\]/,/\[resources\.sources\./ {
                    s|${arch}\.url = \"https://packages.gitlab.com/gitlab/gitlab-${ed}/packages/debian/${debian_version}/gitlab-${ed}_[^\"]*\"|${arch}.url = \"https://packages.gitlab.com/gitlab/gitlab-${ed}/packages/debian/${debian_version}/gitlab-${ed}_${version}-${ed}.0_${arch}.deb/download.deb\"|
                    s|${arch}\.sha256 = \"[^\"]*\"|${arch}.sha256 = \"${sha256_map[${debian_version}_${arch}]}\"|
                }" "$manifest_file"
            done
        done

        echo "Updated latest sources for ${ed^^}"
    fi

    # Add versioned sources for upgrade path
    if [ "$add_only" = true ]; then
        # Check if this version already exists for this edition
        test_source=$(get_versioned_source_suffix "$ed" "bookworm")
        if ! grep -q "\\[resources.sources.${test_source}\\]" "$manifest_file"; then

            # Find the last latest_* section for this edition
            if [ "$ed" = "ee" ]; then
                # For EE: find the last latest_ee_* section
                last_section_pattern="latest_ee_trixie"
            else
                # For CE: find the last latest_* (non-ee) section
                last_section_pattern="latest_trixie"
            fi

            # Find the line number of the last section header
            last_section_line=$(grep -n "\\[resources\\.sources\\.${last_section_pattern}\\]" "$manifest_file" | cut -d: -f1)

            if [ -n "$last_section_line" ]; then
                # Find the end of this section (next section header or end of file)
                total_lines=$(wc -l < "$manifest_file")
                insert_line=$last_section_line

                # Read lines after the section header to find where it ends
                while [ $insert_line -lt $total_lines ]; do
                    insert_line=$((insert_line + 1))
                    line=$(sed -n "${insert_line}p" "$manifest_file")
                    # Stop when we hit another section header
                    if [[ "$line" =~ ^\s*\[resources\.sources\. ]]; then
                        insert_line=$((insert_line - 1))
                        break
                    fi
                    # Stop at empty line (end of section)
                    if [[ -z "$line" || "$line" =~ ^[[:space:]]*$ ]]; then
                        break
                    fi
                done

                # Build the new source entries in a temp file
                temp_sources=$(mktemp)
                {
                    echo ""
                    echo "        # GitLab ${ed^^} $version"
                    first=true
                    for debian_version in "${debian_versions[@]}"; do
                        if [ -z "${sha256_map[${debian_version}_amd64]}" ]; then
                            continue
                        fi

                        # Add empty line between sections (but not before first one)
                        if [ "$first" = true ]; then
                            first=false
                        else
                            echo ""
                        fi

                        source_suffix=$(get_versioned_source_suffix "$ed" "$debian_version")
                        echo "        [resources.sources.${source_suffix}]"
                        echo "            prefetch = false"
                        echo "            extract = false"
                        echo "            rename = \"gitlab-${ed}.deb\""
                        for arch in "${architectures[@]}"; do
                            echo "            ${arch}.url = \"https://packages.gitlab.com/gitlab/gitlab-${ed}/packages/debian/${debian_version}/gitlab-${ed}_${version}-${ed}.0_${arch}.deb/download.deb\""
                            echo "            ${arch}.sha256 = \"${sha256_map[${debian_version}_${arch}]}\""
                        done
                    done
                    echo ""
                } > "$temp_sources"

                # Insert after the last line of the current section
                {
                    head -n "$insert_line" "$manifest_file"
                    cat "$temp_sources"
                    tail -n +"$((insert_line + 1))" "$manifest_file"
                } > "${manifest_file}.tmp"
                mv "${manifest_file}.tmp" "$manifest_file"
                rm -f "$temp_sources"

                echo "Added versioned sources for ${ed^^} $version"
            fi
        else
            echo "Version $version already exists for ${ed^^}, skipping"
        fi
    fi

    # Clear the associative array for next iteration
    unset sha256_map
    declare -A sha256_map

    echo ""
done

echo "Updating manifest.toml..."

# Update gitlab.rb only when not in add-only mode
if [ "$add_only" = false ]; then
    echo ""
    echo "========================================="
    echo "Updating gitlab.rb configuration..."
    echo "========================================="
    echo ""

    conf_file="$current_dir/conf/gitlab.rb"
    # Use CE template (CE and EE templates are identical for gitlab.rb)
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

    sed -i "s/external_url 'GENERATED_EXTERNAL_URL'/external_url '__GENERATED_EXTERNAL_URL__'/" "$conf_file"
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

    sed -i "/^# EOS/r "<(echo "$ldap_conf") "$conf_file"
    sed -i "s/# gitlab_rails\['gitlab_shell_ssh_port'\] = 22/gitlab_rails['gitlab_shell_ssh_port'] = __SSH_PORT__/" "$conf_file"
    sed -i "s/# puma\['port'\] = .*/puma['port'] = __PORT_PUMA__/" "$conf_file"
    sed -i "s/# sidekiq\['listen_port'\] = .*/sidekiq['listen_port'] = __PORT_SIDEKIQ__/" "$conf_file"
    sed -i "s/# nginx\['client_max_body_size'\] = .*/nginx['client_max_body_size'] = '__CLIENT_MAX_BODY_SIZE__'/" "$conf_file"
    sed -i "s/# nginx\['listen_port'\] = .*/nginx['listen_port'] = __PORT__/" "$conf_file"
    sed -i "s/# nginx\['listen_https'\] = .*/nginx['listen_https'] = false/" "$conf_file"
    sed -i "s/# package\['modify_kernel_parameters'\] = .*/package['modify_kernel_parameters'] = __MODIFY_KERNEL_PARAMETERS__/" "$conf_file"

    echo "gitlab.rb updated"
fi

echo ""
echo "========================================="
echo "Update complete!"
echo "========================================="
echo ""

if [ "$add_only" = true ]; then
    echo "Summary:"
    echo "  - Added versioned source entries for: ${editions_to_process[*]}"
    echo "  - latest_* entries were NOT modified"
    echo "  - Package version was NOT modified"
    echo ""
    echo "Please review the changes and commit:"
    echo "  git diff manifest.toml"
    echo "  git add manifest.toml"
    echo "  git commit -m \"Add GitLab $version sources for upgrade path\""
else
    echo "Summary:"
    echo "  - Updated latest sources for: ${editions_to_process[*]}"
    echo "  - Updated package version to ${version}~ynh1"
    echo "  - Updated conf/gitlab.rb from upstream"
    echo ""
    echo "Please review the changes and commit:"
    echo "  git diff manifest.toml conf/gitlab.rb"
    echo "  git add manifest.toml conf/gitlab.rb"
    echo "  git commit -m \"Upgrade GitLab to $version\""
fi
