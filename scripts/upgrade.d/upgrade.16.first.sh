#!/bin/bash

gitlab_version="16.1.6"

# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_bullseye_source_sha256="482f1fef771939a9369f5be06ac8800b9b37562fd4569656f38ebe93705a7f74"
gitlab_x86_64_buster_source_sha256="f800972861c42870c41ca005e5a068130d72cce32d20b71777725866582b7e0b"

gitlab_arm64_bullseye_source_sha256="b68658cd488a459300bb546796a8ac84702c89cf7ad31ead4a28c7b8d2b1a655"
gitlab_arm64_buster_source_sha256="af1a03f3b11c95a9466df27742b32106be2cafa0d56697122d7d4cf2a8dcfd18"

gitlab_arm_buster_source_sha256="a688b26a70a4e51860770517dc773d1b046f33f93deb14687b7a2dc263e5ed82"
gitlab_arm_bullseye_source_sha256="665e096669c7af0ae692ff7da8766dc47579b93664f18387765e8f947b1bc276"

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
