#!/bin/bash

gitlab_version="14.3.0"

# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="buster"

gitlab_x86_64_buster_source_sha256="c5cfb7b1cfda23ff5d0b0a6651850cc838f5488915f76a28fc7ae80b13f88225"

gitlab_arm64_buster_source_sha256="f52869377d872a6514e96b89149d42c97698517d40f86d9de607ce2b8cbc2520"

gitlab_arm_buster_source_sha256="b884b64b743b64d05907ed24c1ec50313d30a7b0e43f3bd1e223ae6d215cd1c0"

architecture=$(ynh_app_setting_get --app="$app" --key=architecture)

if [ "$architecture" = "x86-64" ]; then
	gitlab_source_sha256=$gitlab_x86_64_buster_source_sha256
elif [ "$architecture" = "arm64" ]; then
	gitlab_source_sha256=$gitlab_arm64_buster_source_sha256
elif [ "$architecture" = "arm" ]; then
	# If the version for arm doesn't exist, then use an older one
	if [ -z "$gitlab_arm_buster_source_sha256" ]; then
		gitlab_version="14.3.0"
		gitlab_arm_buster_source_sha256="b884b64b743b64d05907ed24c1ec50313d30a7b0e43f3bd1e223ae6d215cd1c0"
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
