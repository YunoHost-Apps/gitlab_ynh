#!/bin/bash

gitlab_version="13.12.4"

# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="buster"

gitlab_x86_64_buster_source_sha256="76bb8b86edeec1fc4ed7c4169b47ed2ac0a86d0f0dcc9907e79e7ea1219d2b8e"

gitlab_arm64_buster_source_sha256="914bf42acb71b660e512b1b99002787c3fce354f3f6eaa2eaee1fb85afd78e67"

gitlab_arm_buster_source_sha256="68ed3dab94277365cded17b03f01a9347a09370c0dfe3144e9d2938eb83268e1"

architecture=$(ynh_app_setting_get --app="$app" --key=architecture)

if [ "$architecture" = "x86-64" ]; then
	gitlab_source_sha256=$gitlab_x86_64_buster_source_sha256
elif [ "$architecture" = "arm64" ]; then
	gitlab_source_sha256=$gitlab_arm64_buster_source_sha256
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
