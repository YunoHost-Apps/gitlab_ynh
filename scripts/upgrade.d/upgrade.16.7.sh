#!/bin/bash

gitlab_version="16.7.5"

# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_bullseye_source_sha256="dc5bd5815d3a40303f65c2655b728dd0bc1839d808c3f77062452ede16272591"
gitlab_x86_64_buster_source_sha256="eae0ba2bb22e66368d5e68c1088f9c8923f371cbc354e7a40bfb90e3f3ddff94"

gitlab_arm64_bullseye_source_sha256="3c74043e93aba65a870187262de3e175b6407f6136bc018972b646e9c94b9b91"
gitlab_arm64_buster_source_sha256="379ca2ae9151fca4220880db68afdf8237b22ab7ac6084818c71266c096843ea"

gitlab_arm_buster_source_sha256="bc1b7c9d5addf05290b207f8d53e8d7ddcf0e871316d80afa8eaa8f875d08a71"
gitlab_arm_bullseye_source_sha256="5cd2920d3a7e64ed74bbf5f0df5a237a2caf8fa859c82fee074e04c61561d9bd"

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
