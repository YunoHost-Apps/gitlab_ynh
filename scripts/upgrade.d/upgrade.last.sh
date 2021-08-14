#!/bin/bash

gitlab_version="14.1.2"

# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="buster"

gitlab_x86_64_buster_source_sha256="01e1776daa7ed6062117b7c2ae9425eed6ba200f07192bd52d4fa6febe45f46d"

gitlab_arm64_buster_source_sha256="f2804db2d0286b6c22efe8671734f56e5f08fd91e2820173b833daa0efae247b"

gitlab_arm_buster_source_sha256="33a33792cbdceed4e64a815997fc06df83aaaab2bac8209f6776da821d25d494"

architecture=$(ynh_app_setting_get --app="$app" --key=architecture)

if [ "$architecture" = "x86-64" ]; then
	gitlab_source_sha256=$gitlab_x86_64_buster_source_sha256
elif [ "$architecture" = "arm64" ]; then
	gitlab_source_sha256=$gitlab_arm64_buster_source_sha256
elif [ "$architecture" = "arm" ]; then
	# If the version for arm doesn't exist, then use an older one
	if [ -z "$gitlab_arm_buster_source_sha256" ]; then
		gitlab_version="14.1.2"
		gitlab_arm_buster_source_sha256="33a33792cbdceed4e64a815997fc06df83aaaab2bac8209f6776da821d25d494"
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
