#!/bin/bash

gitlab_version="13.10.3"

# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="buster"

gitlab_x86_64_buster_source_sha256="75def5cb7f581cc06ed0dc089d4c2803003af6a5bd40a6badcc00d81a99856b0"

gitlab_arm64_buster_source_sha256="9170a0027c56df19e8a3836bb164f7cd08553f69ec4acb571364a507cdbd3394"

gitlab_arm_buster_source_sha256="043194f93a6484f87807b8dd880340ec8db5676ee6bbbaa1ac3c26d498260392"

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
