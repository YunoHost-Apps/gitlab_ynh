#!/bin/bash

gitlab_version="15.0.4"

# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_bullseye_source_sha256="2958fc7f986ab0f6d71d297a0f9d1eca65b25c7a2da176c607db75f056cef5ca"
gitlab_x86_64_buster_source_sha256="0c803fb16d4a3767cb9d29c9b7fd01480d203b0e633626692ec1b2cfab4e06dd"

gitlab_arm64_bullseye_source_sha256="c9b5e4e8ce80f72f750bf0d9cbebcbc9042be8176eb805661db8f92e48041460"
gitlab_arm64_buster_source_sha256="28caaa6bb0c55f06cfaf93ffea22d0567bfc1d5395a44bc2549318655b5243c8"

gitlab_arm_buster_source_sha256="49a1d860eb533baa3e2037b0dd73ada0e5c6709ac4c9d53db2d045bc385f0292"

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
