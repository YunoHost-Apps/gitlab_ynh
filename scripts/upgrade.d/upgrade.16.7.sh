#!/bin/bash

gitlab_version="16.7.10"

# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_bullseye_source_sha256="db442d21fc9f653a66990848e61fb5989902f06ca274cd194670082837338af9"
gitlab_x86_64_buster_source_sha256="1a010819d9c4befadd576b9cba5a2c8cb179dc87169f9ba12492e953fbd9b0e1"

gitlab_arm64_bullseye_source_sha256="1873eb333148c2b786697c81c317cde2ed87ad4d79b41077ae63526df4c129f4"
gitlab_arm64_buster_source_sha256="d865000cb8026e72dcb018d29d68258c05e2049cd75d153ebf8b71de167d348d"

gitlab_arm_buster_source_sha256="b8ce1cdd9cbc8c01dffb5fd8bff96bee8b38e38ea3765115935df36dd50deabd"
gitlab_arm_bullseye_source_sha256="ff0d8639e55e484a87d082f06d5bbafea674841f94ef2b90277cd9f8ec7c1e40"

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
