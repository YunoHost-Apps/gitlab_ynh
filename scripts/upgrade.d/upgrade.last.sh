#!/bin/bash

gitlab_version="14.10.0"

# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_bullseye_source_sha256="6f7a1ba6c263f0eaeee909a2c3134b894aae3c203de37d7e2ebffd67e9949619"
gitlab_x86_64_buster_source_sha256="85489ced3b9ae2ba87c6e76c4fcb0a5cf0b6f93cf302ab22bb73e50ba233aa19"

gitlab_arm64_bullseye_source_sha256="4b47d2acd4adc2f11217e162559cb128b32961a88d3aecd668847077f83d6a37"
gitlab_arm64_buster_source_sha256="611f7a3184d1708cc1ad1d271e76104f1e3ec56e92bcf4bcb164760bd87b83dc"

gitlab_arm_buster_source_sha256="da62ffd3aba70b37f583a78000ecb0eeab774fe7e5de437e8823bd45b375ba02"

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
		gitlab_version="14.10.0"
		gitlab_arm_buster_source_sha256="da62ffd3aba70b37f583a78000ecb0eeab774fe7e5de437e8823bd45b375ba02"
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
