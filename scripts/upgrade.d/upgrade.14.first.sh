#!/bin/bash

gitlab_version="14.0.6"

# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="buster"

gitlab_x86_64_buster_source_sha256="2ea56af1df12b823225de4c0ec1d06b1e143ca7d8eea2ab56b82ddeb94a6d0e8"

gitlab_arm64_buster_source_sha256="84530fef7ab7ade92e5e64461fbdea9b22e7264af6005b9782b816d0ac66c77d"

gitlab_arm_buster_source_sha256="f3f625c422ecf442d382fbc61222f86b0b0bf635dc96e09e703b2dd8b17cb7ed"

architecture=$(ynh_app_setting_get --app="$app" --key=architecture)

if [ "$architecture" = "x86-64" ]; then
	gitlab_source_sha256=$gitlab_x86_64_buster_source_sha256
elif [ "$architecture" = "arm64" ]; then
	gitlab_source_sha256=$gitlab_arm64_buster_source_sha256
elif [ "$architecture" = "arm" ]; then
	# If the version for arm doesn't exist, then use an older one
	if [ -z "$gitlab_arm_buster_source_sha256" ]; then
		gitlab_version="14.0.6"
		gitlab_arm_buster_source_sha256="f3f625c422ecf442d382fbc61222f86b0b0bf635dc96e09e703b2dd8b17cb7ed"
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
