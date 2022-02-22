#!/bin/bash

gitlab_version="14.8.0"

# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_bullseye_source_sha256="defaf15ae7ab2a901d7be1a1b97afe6d849c1eff7b2ad7df184eb9971ebd2263"
gitlab_x86_64_buster_source_sha256="ce503bf0ff42d2499358945115ad557f15a3a60a39c166776d4db76a1044bcc9"

gitlab_arm64_bullseye_source_sha256="fe2fa71f00239cba7ed43b5482969ba8cbcb10fe89199bd8d5ee607699007bdb"
gitlab_arm64_buster_source_sha256="7b29a329fa1123fa97d1f299149bc5ce5f52db8b2a3bb8084bc8800507740f0f"

gitlab_arm_buster_source_sha256="eca82d58a7b6d2c308ec4fcccf8d176ece5508a2ec5297bd3dfcd826135a762d"

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
		gitlab_version="14.8.0"
		gitlab_arm_buster_source_sha256="eca82d58a7b6d2c308ec4fcccf8d176ece5508a2ec5297bd3dfcd826135a762d"
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
