#!/bin/bash

gitlab_version="14.6.2"

# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_bullseye_source_sha256="5483d1ebf5cafd871e6a393389ddfc599bde70b3e0e28f9ba4c442e852be9ed5"
gitlab_x86_64_buster_source_sha256="1bb42ab71d7cfade9396b342a4087bede0df0c34141342bd713c63ab40a7355d"

gitlab_arm64_bullseye_source_sha256="5cf9a513630a19b4f937794ba6c5e9ade5acee78ca85ee7e810f8070aafc3564"
gitlab_arm64_buster_source_sha256="bc260c280eaa30a419a0b12844e1b1f8951dccc3187fd916caf336427f5f89ca"

gitlab_arm_buster_source_sha256="0a63889fdc3af13f0562432e5c19862747c6639c5c3df7e54384204596a14290"

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
		gitlab_version="14.6.2"
		gitlab_arm_buster_source_sha256="0a63889fdc3af13f0562432e5c19862747c6639c5c3df7e54384204596a14290"
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
