#!/bin/bash

gitlab_version="14.10.2"

# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_bullseye_source_sha256="26cfcc910b051f845e50e0c56e4dec3bad7383594a0efbb788ea1d91808dce9d"
gitlab_x86_64_buster_source_sha256="496861f66ff9948b11ae20692a8d86e305743df67d15f60443d4f9762eda1bb0"

gitlab_arm64_bullseye_source_sha256="f7f9085419b30aa0424bc97678cffbbac7cd08a34b643ccad51785703c290672"
gitlab_arm64_buster_source_sha256="23926737f06832de39d5541cad492b5600acd2bb6a314e20cee1e7f210422903"

gitlab_arm_buster_source_sha256="e63c8d8aadbdaef6991fabab18d9a11e866bfb653d4a516d7ba6b8f2d17d3bed"

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
		gitlab_version="14.10.2"
		gitlab_arm_buster_source_sha256="e63c8d8aadbdaef6991fabab18d9a11e866bfb653d4a516d7ba6b8f2d17d3bed"
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
