#!/bin/bash

gitlab_version="14.3.2"

# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="buster"

gitlab_x86_64_buster_source_sha256="74fa8f0911c30b7ab615d67a29d6e5e2f958fe76ac866d36d1fc8a927298c26f"

gitlab_arm64_buster_source_sha256="33cfad63ab4c6782f41a8a4a990eade9da4a8faaf2fa718e96a8b02d67fdae3a"

gitlab_arm_buster_source_sha256="70ebb828586c5e33a4b4ec58bfe0ca3779cd6e5c421e7b97d9f707d26ab8f62d"

architecture=$(ynh_app_setting_get --app="$app" --key=architecture)

if [ "$architecture" = "x86-64" ]; then
	gitlab_source_sha256=$gitlab_x86_64_buster_source_sha256
elif [ "$architecture" = "arm64" ]; then
	gitlab_source_sha256=$gitlab_arm64_buster_source_sha256
elif [ "$architecture" = "arm" ]; then
	# If the version for arm doesn't exist, then use an older one
	if [ -z "$gitlab_arm_buster_source_sha256" ]; then
		gitlab_version="14.3.2"
		gitlab_arm_buster_source_sha256="70ebb828586c5e33a4b4ec58bfe0ca3779cd6e5c421e7b97d9f707d26ab8f62d"
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
