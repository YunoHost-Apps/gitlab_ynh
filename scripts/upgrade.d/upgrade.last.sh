#!/bin/bash

gitlab_version="15.4.1"

# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_bullseye_source_sha256="0136f97d3a8db2dfb85e7fffe1248a5aa1f61b2b142910225f98e9d570dd497b"
gitlab_x86_64_buster_source_sha256="0099e3876388ade063f88aa720b9208f389a168eb093c68ab07ffbc93b3fe910"

gitlab_arm64_bullseye_source_sha256="5481b71f9b561362d468ad1e53afec7c77a8251404cd0053848f66a8e2e17656"
gitlab_arm64_buster_source_sha256="40d4c07d1c281a8d1dcf3794e715090514c7b627557245e879ec79c22d7efb27"

gitlab_arm_buster_source_sha256="e7febd850d745fa459bb9b02ebad74b7cba4541cb73e3ac7cedc55cbca2b40b2"

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
		gitlab_version="15.4.1"
		gitlab_arm_buster_source_sha256="e7febd850d745fa459bb9b02ebad74b7cba4541cb73e3ac7cedc55cbca2b40b2"
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
