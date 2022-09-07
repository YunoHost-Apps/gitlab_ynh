#!/bin/bash

gitlab_version="15.3.3"

# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_bullseye_source_sha256="ee9a156d49daeca1e5901562e9c0e966b1b9b03379688b466ceb5cac8217632f"
gitlab_x86_64_buster_source_sha256="1f20c8f67119a5025fbc7e0f39a7c936cdbe20cdc7d9dcecf987419e2a3b5e36"

gitlab_arm64_bullseye_source_sha256="d6cbcd4a7d552da0db0c7668eb7815c32894772b74cbb6c4f2d567243c16f25a"
gitlab_arm64_buster_source_sha256="d03c4d5b5cf3d007593c69c73d82ec1d0ee33927dca9acf789756aca01ef7268"

gitlab_arm_buster_source_sha256="41fbc6658e33430f230a34e4b8ac226b5d97aed02fbd386a3cc737cbe07bd95b"

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
		gitlab_version="15.3.3"
		gitlab_arm_buster_source_sha256="41fbc6658e33430f230a34e4b8ac226b5d97aed02fbd386a3cc737cbe07bd95b"
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
