#!/bin/bash

gitlab_version="14.0.11"

# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="buster"

gitlab_x86_64_buster_source_sha256="b001ff2bf406e44a85e0c799e4cbddb8bc3ccef07246502f7f267032aa77263d"

gitlab_arm64_buster_source_sha256="f8d7a9ca77520b7ec045f414a7ac7b28407b9aa8a3825e50cb63cd877e91196a"

gitlab_arm_buster_source_sha256="5f1de707c840e4a518e99c89b0e90a5c21c32cac91e853f1e12ef054696100dd"

architecture=$(ynh_app_setting_get --app="$app" --key=architecture)

if [ "$architecture" = "x86-64" ]; then
	gitlab_source_sha256=$gitlab_x86_64_buster_source_sha256
elif [ "$architecture" = "arm64" ]; then
	gitlab_source_sha256=$gitlab_arm64_buster_source_sha256
elif [ "$architecture" = "arm" ]; then
	# If the version for arm doesn't exist, then use an older one
	if [ -z "$gitlab_arm_buster_source_sha256" ]; then
		gitlab_version="14.0.11"
		gitlab_arm_buster_source_sha256="5f1de707c840e4a518e99c89b0e90a5c21c32cac91e853f1e12ef054696100dd"
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
