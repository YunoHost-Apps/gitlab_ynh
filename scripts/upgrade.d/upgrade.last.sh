#!/bin/bash

gitlab_version="15.1.2"

# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_bullseye_source_sha256="2c29cad38c2db9d2dea9869eabba02a53e72049b8782dc5ccf0848f5c86af3a1"
gitlab_x86_64_buster_source_sha256="81278e1b4d4743b5f142e17e3e351841235ab0b13eb4bd72d72598ab3e92804f"

gitlab_arm64_bullseye_source_sha256="3dbb1bb2e8d75d82f10ecf0f40cf2e2e9d574f377ce93a8caa4479e44a32ddfb"
gitlab_arm64_buster_source_sha256="80fe48ac2083669d5be8aa189dbc9369e87da22eca7162721a4fb3fa579651f6"

gitlab_arm_buster_source_sha256="5d57e7a5c1cef71812712be58b9f4badb54b954597c6adafb0312aa72f8b7f80"

architecture=$(ynh_app_setting_get --app="$app" --key=architecture)

if [ "$architecture" = "x86-64" ]; then
	if [ "$gitlab_debian_version" = "bullseye" ]
	then
		gitlab_source_sha256=$gitlab_x86_64_bullseye_source_sha256
	elif [ "$gitlab_debian_version" = "buster" ]
	then
		gitlab_source_sha256=$gitlab_x86_64_buster_source_sha256
	fi
elif [ "$architecture" = "arm64" ]; then
	if [ "$gitlab_debian_version" = "bullseye" ]
	then
		gitlab_source_sha256=$gitlab_arm64_bullseye_source_sha256
	elif [ "$gitlab_debian_version" = "buster" ]
	then
		gitlab_source_sha256=$gitlab_arm64_buster_source_sha256
	fi
elif [ "$architecture" = "arm" ]; then
	# If the version for arm doesn't exist, then use an older one
	if [ -z "$gitlab_arm_buster_source_sha256" ]; then
		gitlab_version="15.1.2"
		gitlab_arm_buster_source_sha256="5d57e7a5c1cef71812712be58b9f4badb54b954597c6adafb0312aa72f8b7f80"
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
