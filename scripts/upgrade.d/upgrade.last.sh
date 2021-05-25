#!/bin/bash

gitlab_version="13.12.0"

# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="buster"

gitlab_x86_64_buster_source_sha256="0bea726c7c423ec34cf5e620a6a2bf2a55c7c55e4f67070aa6ea96d02015ccc6"

gitlab_arm64_buster_source_sha256="a2136f9311ceaf563f6b2594aefef68c89008c7b84082e97e87596061b5b4603"

gitlab_arm_buster_source_sha256="4fda3882ef7464c4679d0d6a6720630f45ac988cad6f3e7f33e4e02e36c0d03f"

architecture=$(ynh_app_setting_get --app="$app" --key=architecture)

if [ "$architecture" = "x86-64" ]; then
	gitlab_source_sha256=$gitlab_x86_64_buster_source_sha256
elif [ "$architecture" = "arm64" ]; then
	gitlab_source_sha256=$gitlab_arm64_buster_source_sha256
elif [ "$architecture" = "arm" ]; then
	gitlab_source_sha256=$gitlab_arm_buster_source_sha256
fi

gitlab_filename="gitlab-ce-${gitlab_version}.deb"

# Action to do in case of failure of the package_check
package_check_action() {
	ynh_backup_if_checksum_is_different --file="$config_path/gitlab.rb"
	cat <<EOF >> "$config_path/gitlab.rb"
# Last chance to fix Gitlab
package['modify_kernel_parameters'] = false
EOF
	ynh_store_file_checksum --file="$config_path/gitlab.rb"
}
