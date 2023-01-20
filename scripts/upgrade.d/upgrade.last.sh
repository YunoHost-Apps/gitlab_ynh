#!/bin/bash

gitlab_version="15.7.5"

# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_bullseye_source_sha256="1636a7bc19d7511e8c4a24a8f143e147c135ccf8ae16edab431a699840f8eb3e"
gitlab_x86_64_buster_source_sha256="2c296c01c5662b053de1117d711e09eaafdfe0e1a446853062bfb0589d58bac7"

gitlab_arm64_bullseye_source_sha256="615e0d68ec48b327709e61199acff77b7d67862af1a10ecbd762b9c8a45bc59e"
gitlab_arm64_buster_source_sha256="4bbd36a263a083647f8a6518cd06b997b62750aecf87642c24c8f7b149f12299"

gitlab_arm_buster_source_sha256="81a9bd3a91f53052be88684d11bf97978be3bdc0636817e730728f2f91c83c63"
gitlab_arm_bullseye_source_sha256="e64294e57e19f1b86ddccee67679bdc987adbdec918e40237ada630b7b9f3a42"

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
			gitlab_version="15.7.5"
			gitlab_arm_buster_source_sha256="81a9bd3a91f53052be88684d11bf97978be3bdc0636817e730728f2f91c83c63"
		fi
		gitlab_source_sha256=$gitlab_arm_buster_source_sha256
	elif [ "$gitlab_debian_version" = "buster" ]
	then
		# If the version for arm doesn't exist, then use an older one
		if [ -z "$gitlab_arm_bullseye_source_sha256" ]; then
			gitlab_version="15.7.5"
			gitlab_arm_bullseye_source_sha256="e64294e57e19f1b86ddccee67679bdc987adbdec918e40237ada630b7b9f3a42"
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
