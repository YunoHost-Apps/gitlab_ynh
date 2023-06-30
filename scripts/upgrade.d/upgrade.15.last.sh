#!/bin/bash

gitlab_version="15.11.5"

# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_bullseye_source_sha256="1cc7b52bf8380368321b6aed6eaea6aa08d6f1eca2f11317db0cc64a82c815de"
gitlab_x86_64_buster_source_sha256="49af6b95b9c9eec501e2d8d9d46b89d7958464d7a467892cdaf7e8e435f6b2ce"

gitlab_arm64_bullseye_source_sha256="7712859bc457b262cb33c0ca04c17f7f32013592bc1c96fa86a9621d538f68bc"
gitlab_arm64_buster_source_sha256="0b633b20f05794d703ebf21d641be2a00fdcb1b7ac4d3a9ff5326b66fae14f68"

gitlab_arm_buster_source_sha256="838c832db002b3db16d52f92f2d1390737e43ad81dff78b185829d01ce4e2096"
gitlab_arm_bullseye_source_sha256="fdbe645ef18cfeeef2fc15c9979c6ced35f6717873538b2ade934e3e24b1dd51"

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
