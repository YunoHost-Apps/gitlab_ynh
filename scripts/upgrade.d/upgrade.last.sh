#!/bin/bash

gitlab_version="14.1.0"

# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="buster"

gitlab_x86_64_buster_source_sha256="4a3a7c4eb7bb07df1052e20a68134071b43ea57b563906af390785c200ec1f77"

gitlab_arm64_buster_source_sha256="543569641dc3629dfff2c0c913b23acfc2b4a567e2e846c8b0ee8c62e6f7905b"

gitlab_arm_buster_source_sha256="25491d5df45ad0f34771eca120ca7b01ab8e606f0915ec7a7e5f4d3a76d4f4a9"

architecture=$(ynh_app_setting_get --app="$app" --key=architecture)

if [ "$architecture" = "x86-64" ]; then
	gitlab_source_sha256=$gitlab_x86_64_buster_source_sha256
elif [ "$architecture" = "arm64" ]; then
	gitlab_source_sha256=$gitlab_arm64_buster_source_sha256
elif [ "$architecture" = "arm" ]; then
	# If the version for arm doesn't exist, then use an older one
	if [ -z "$gitlab_arm_buster_source_sha256" ]; then
		gitlab_version="14.1.0"
		gitlab_arm_buster_source_sha256="25491d5df45ad0f34771eca120ca7b01ab8e606f0915ec7a7e5f4d3a76d4f4a9"
	fi
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
