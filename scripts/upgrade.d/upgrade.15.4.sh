#!/bin/bash

gitlab_version="15.4.6"

# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_bullseye_source_sha256="1e328997adb13fca9fb829218d6556c14065d9889997e6b7330f554cf812455a"
gitlab_x86_64_buster_source_sha256="9fd1cc1fde6dbc1ec3c5528eea74f57c355f098ed26d5ad914ce30e2acd5764e"

gitlab_arm64_bullseye_source_sha256="fff8625d2cbdb45bc3d90e4414ac6b4b9023a24526ab73f0f86d7177e3129915"
gitlab_arm64_buster_source_sha256="3c35b28717a06b17ce7854c76d0ab35dc73554061ad3881170be68b072a53cf7"

gitlab_arm_buster_source_sha256="33a60e701921117542de771b8c0e2c83c7cbd2730f199e4c88c8adc6eb1c4579"

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
