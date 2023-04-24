#!/bin/bash

gitlab_version="15.11.0"

# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_bullseye_source_sha256="af34ec336f4f2552fa0725a7b64f81693dc8fd1c61dece50de17d9698ec779f4"
gitlab_x86_64_buster_source_sha256="e68681a256d7c333894f6ae1d261945f782f44f0f3ee3b4f7bb5ca10f1eef4bf"

gitlab_arm64_bullseye_source_sha256="2c0f26c0b5733594f4b66a8934e543ab8707f0f59e807638ccd7d024e3cb4090"
gitlab_arm64_buster_source_sha256="9b83d92f6167b8cf5a28748ed29b06c2edd0f7d2005d1ae8f8f06ed69a70d9f8"

gitlab_arm_buster_source_sha256="aa9423ae404df614911cbee432080837025d1a566967d1e0d5034d68b1c281cc"
gitlab_arm_bullseye_source_sha256="1d8a25012b380242defc3c87e33ce6434815fb8d4f9d92ebe5b891e1067ddd6d"

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
		# If the version for arm doesn't exist, then use an older one
		if [ -z "$gitlab_arm_buster_source_sha256" ]; then
			gitlab_version="15.11.0"
			gitlab_arm_buster_source_sha256="aa9423ae404df614911cbee432080837025d1a566967d1e0d5034d68b1c281cc"
		fi
		gitlab_source_sha256=$gitlab_arm_buster_source_sha256
	elif [ "$gitlab_debian_version" = "buster" ]
	then
		# If the version for arm doesn't exist, then use an older one
		if [ -z "$gitlab_arm_bullseye_source_sha256" ]; then
			gitlab_version="15.11.0"
			gitlab_arm_bullseye_source_sha256="1d8a25012b380242defc3c87e33ce6434815fb8d4f9d92ebe5b891e1067ddd6d"
		fi
		gitlab_source_sha256=$gitlab_arm_bullseye_source_sha256
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
