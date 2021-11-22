#!/bin/bash

gitlab_version="14.5.0"

# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="buster"

gitlab_x86_64_buster_source_sha256="9665cde5950fb531bde2c585fbab6a76e6a9677868dc573d6435003b580833d4"

gitlab_arm64_buster_source_sha256="bb0372c1fe0aa8f7f741c3e0b709374309a1aa82462c391be4800fca189d209e"

gitlab_arm_buster_source_sha256="9c7b3bf6704f4937d69ec7a5f3abeda2fcfe59721887d1012be3bca472cc13e7"

architecture=$(ynh_app_setting_get --app="$app" --key=architecture)

if [ "$architecture" = "x86-64" ]; then
	gitlab_source_sha256=$gitlab_x86_64_buster_source_sha256
elif [ "$architecture" = "arm64" ]; then
	gitlab_source_sha256=$gitlab_arm64_buster_source_sha256
elif [ "$architecture" = "arm" ]; then
	# If the version for arm doesn't exist, then use an older one
	if [ -z "$gitlab_arm_buster_source_sha256" ]; then
		gitlab_version="14.5.0"
		gitlab_arm_buster_source_sha256="9c7b3bf6704f4937d69ec7a5f3abeda2fcfe59721887d1012be3bca472cc13e7"
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
