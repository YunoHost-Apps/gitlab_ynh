#!/bin/bash

gitlab_version="14.8.2"

# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_bullseye_source_sha256="c01632f7ffbc03f036e2c567ddca68331d511079d601c74c84ec9afb8eef1fa3"
gitlab_x86_64_buster_source_sha256="ba982225a49fff988461a44be45062238514a2efb15bc9f05fd452485b5a4166"

gitlab_arm64_bullseye_source_sha256="58ef4bafdda9005f4e4ca9abd6c88e77206c837df25c037a4cdcf1e219e4db5a"
gitlab_arm64_buster_source_sha256="e0c351e2f123e37017f4bb4313176332df81a2b37372f1564bb5ab297af409a0"

gitlab_arm_buster_source_sha256="0ba82ce3941120c46a883ea9406ccf78f352f88e394794b124e1c79a4c3b089f"

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
	gitlab_source_sha256=$gitlab_arm64_buster_source_sha256
elif [ "$architecture" = "arm" ]; then
	# If the version for arm doesn't exist, then use an older one
	if [ -z "$gitlab_arm_buster_source_sha256" ]; then
		gitlab_version="14.8.2"
		gitlab_arm_buster_source_sha256="0ba82ce3941120c46a883ea9406ccf78f352f88e394794b124e1c79a4c3b089f"
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
