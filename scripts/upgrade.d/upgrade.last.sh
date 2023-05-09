#!/bin/bash

gitlab_version="15.11.2"

# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_bullseye_source_sha256="6bb86d2f687aae09e4d75563dbf45ed0722a4a134e8c41d611463f3c557879e2"
gitlab_x86_64_buster_source_sha256="d86560e5df68a11a4d1a3fdd732ef2ea3ea76fcd5e212240d1c02551d03ad580"

gitlab_arm64_bullseye_source_sha256="be8665f68254605fc19f192256d3584d460e54f9389454907400a936ec29fb66"
gitlab_arm64_buster_source_sha256="2273402385a35f838bdc0d7facc81b5c2c2aa18d3b5bf428d83d94b8a1499fc8"

gitlab_arm_buster_source_sha256="34382e3c587a6a6695a80001956e98d39c1d45b5747a537d38c62b1c35f03e8d"
gitlab_arm_bullseye_source_sha256="e9665761aa44210699cf5d2bea2672f7499c125c4bccc2cc45dc9296dd33520a"

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
	if [ "$gitlab_debian_version" = "bullseye" ]
	then
		# If the version for arm doesn't exist, then use an older one
		if [ -z "$gitlab_arm_buster_source_sha256" ]; then
			gitlab_version="15.11.2"
			gitlab_arm_buster_source_sha256="34382e3c587a6a6695a80001956e98d39c1d45b5747a537d38c62b1c35f03e8d"
		fi
		gitlab_source_sha256=$gitlab_arm_buster_source_sha256
	elif [ "$gitlab_debian_version" = "buster" ]
	then
		# If the version for arm doesn't exist, then use an older one
		if [ -z "$gitlab_arm_bullseye_source_sha256" ]; then
			gitlab_version="15.11.2"
			gitlab_arm_bullseye_source_sha256="e9665761aa44210699cf5d2bea2672f7499c125c4bccc2cc45dc9296dd33520a"
		fi
		gitlab_source_sha256=$gitlab_arm_bullseye_source_sha256
	fi
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
