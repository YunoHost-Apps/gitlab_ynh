#!/bin/bash

gitlab_version="16.7.4"

# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_bullseye_source_sha256="f5a4771960395864b199cad65dd196f542a47cd98f6caa164aecfc2bd2e919aa"
gitlab_x86_64_buster_source_sha256="2e4c1caffce05164a79c530bc51fd654145b07d0539fa34e869e59bc9b10932b"

gitlab_arm64_bullseye_source_sha256="99e9ba4588df220f06c23e265921664067c0133bd38179077ff350fdbfeaf0ce"
gitlab_arm64_buster_source_sha256="da0c5d57eb54f3eb3a6690e4bc6eae05251871aa3a6bb41d523eca94e95a4765"

gitlab_arm_buster_source_sha256="bc8190866e5e2ebe67a63f04614405b83e41b54aab8c8ca3fb50bfd7f0cc2196"
gitlab_arm_bullseye_source_sha256="63735b16dfa5825dfb92685565faec5274a3f38497494520a6142a3edf3dc298"

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
