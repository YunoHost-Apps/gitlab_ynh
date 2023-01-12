#!/bin/bash

gitlab_version="15.7.3"

# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_bullseye_source_sha256="12e4e36764fa1ef172038a0307e677956950ef36acc46e4f7e01d5daeebc6e4b"
gitlab_x86_64_buster_source_sha256="89a7e6eff4375e898451966f16ab75e3cc5591568c76578e94c7f6ac099215b6"

gitlab_arm64_bullseye_source_sha256="8c1c9f5a6475e036f5306d374bdc05f23a9140986949a118928c316dca356d32"
gitlab_arm64_buster_source_sha256="a1ad0659ddd2be0d5d4a173cd1dade8c3ffbb927361731c71657b7847c43f94c"

gitlab_arm_buster_source_sha256="336ffaf66926430d9af12d0ef9d1c194fc2a2fcfbb89e8ab128a41a2e6bc14ac"
gitlab_arm_bullseye_source_sha256="90861ee57b1e695350faa424d7e12a9edfdf03f6532403a77aeb31ca3e30c89a"

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
			gitlab_version="15.7.3"
			gitlab_arm_buster_source_sha256="336ffaf66926430d9af12d0ef9d1c194fc2a2fcfbb89e8ab128a41a2e6bc14ac"
		fi
		gitlab_source_sha256=$gitlab_arm_buster_source_sha256
	elif [ "$gitlab_debian_version" = "buster" ]
	then
		# If the version for arm doesn't exist, then use an older one
		if [ -z "$gitlab_arm_bullseye_source_sha256" ]; then
			gitlab_version="15.7.3"
			gitlab_arm_bullseye_source_sha256="90861ee57b1e695350faa424d7e12a9edfdf03f6532403a77aeb31ca3e30c89a"
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
