#!/bin/bash

gitlab_version="15.1.1"

# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_bullseye_source_sha256="10820e063bb643cf3857b05c49815b161c702f8e464bdb30d72a40fbbf5fb658"
gitlab_x86_64_buster_source_sha256="9c4ccd1f3f1b5c1c98ffe8c5bde3fcb27e8aab2d9ce746cd6d8e3e223838fbbf"

gitlab_arm64_bullseye_source_sha256="a0f30c4616ad8ab0c5c302dc2199e1ac6514651833b0448d8ddc6c3f7a1be77c"
gitlab_arm64_buster_source_sha256="a9e5d670a331a9dc0c24df8615ef0752831ac4a06a420aee58943ce28ff16ddc"

gitlab_arm_buster_source_sha256="ed497c76ce8b60e9bbeced8a212445c7b427bd6aff51eb1b96289e756a3986e8"

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
		gitlab_version="15.1.1"
		gitlab_arm_buster_source_sha256="ed497c76ce8b60e9bbeced8a212445c7b427bd6aff51eb1b96289e756a3986e8"
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
