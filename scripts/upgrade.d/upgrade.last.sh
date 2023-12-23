#!/bin/bash

gitlab_version="16.7.0"

# Upgrade path: https://gitlab-com.gitlab.io/support/toolbox/upgrade-path/
# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_bookworm_source_sha256="9d33fff0f783a279cbb584dd92efe05b66c28221b221bae46a415095e30e4ab1"
gitlab_x86_64_bullseye_source_sha256="59ba37669dae0ecb69186e82468ab73455d2e050e5e4ede04fe648bf2ed47961"
gitlab_x86_64_buster_source_sha256="115762553a695546e63dcb270f00ca5e8000e0bd08d676432c29b4d34c2b4e19"

gitlab_arm64_bookworm_source_sha256="abc27b8c09247c3127f95977616b1811be101cf253c60cef5fdf7e4dbe698e09"
gitlab_arm64_bullseye_source_sha256="cc28d443d6292289172cba777ed9553d7f8804af2797bc504275909d313868f1"
gitlab_arm64_buster_source_sha256="6d67bf9b71cd34ea888e69c24e4ba22e56c183692edaadc63c8e71ea2970b178"

gitlab_arm_bookworm_source_sha256=""
gitlab_arm_bullseye_source_sha256="f523966acb8b569e9aab7c5c112ea355383d16b7ff7ec4329d38ad467cd316be"
gitlab_arm_buster_source_sha256="751bdb877b3508c23d41860500e038ba1451e5c772aa01388d14287b3f6aa340"

architecture=$(ynh_app_setting_get --app="$app" --key=architecture)

# Evaluating indirect/reference variables https://mywiki.wooledge.org/BashFAQ/006#Indirection 
# ref=gitlab_${architecture}_${gitlab_debian_version}_source_sha256
# gitlab_source_sha256=${!ref}

if [ "$architecture" = "x86-64" ]; then
	if [ "$gitlab_debian_version" = "bookworm" ]
	then
		gitlab_source_sha256=$gitlab_x86_64_bookworm_source_sha256
	elif [ "$gitlab_debian_version" = "bullseye" ]
	then
		gitlab_source_sha256=$gitlab_x86_64_bullseye_source_sha256
	elif [ "$gitlab_debian_version" = "buster" ]
	then
		gitlab_source_sha256=$gitlab_x86_64_buster_source_sha256
	fi
elif [ "$architecture" = "arm64" ]; then
	if [ "$gitlab_debian_version" = "bookworm" ]
	then
		gitlab_source_sha256=$gitlab_arm64_bookworm_source_sha256
	elif [ "$gitlab_debian_version" = "bullseye" ]
	then
		gitlab_source_sha256=$gitlab_arm64_bullseye_source_sha256
	elif [ "$gitlab_debian_version" = "buster" ]
	then
		gitlab_source_sha256=$gitlab_arm64_buster_source_sha256
	fi
elif [ "$architecture" = "arm" ]; then
	if [ "$gitlab_debian_version" = "bookworm" ]
	then
		gitlab_source_sha256=$gitlab_arm_bookworm_source_sha256
		if [ -z "$gitlab_arm_bookworm_source_sha256" ]
		then
			gitlab_source_sha256=$gitlab_arm_bullseye_source_sha256
		fi
	elif [ "$gitlab_debian_version" = "bullseye" ]
	then
		gitlab_source_sha256=$gitlab_arm_bullseye_source_sha256
	elif [ "$gitlab_debian_version" = "buster" ]
	then
		gitlab_source_sha256=$gitlab_arm_buster_source_sha256
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
