#!/bin/bash

gitlab_version="14.2.1"

# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="buster"

gitlab_x86_64_buster_source_sha256="3e7246f2b49a9cb608714bc32f330e2b21d1b6f37cf44c31374a8817a16faf96"

gitlab_arm64_buster_source_sha256="5967ee8f5b975f26a30469ea9d9492ce4cee06d958e292d1057c30fb9d3ff735"

gitlab_arm_buster_source_sha256="f4553bb6a04fa580f2a4eb5ec5507701ae1c1cb4766cad58568d299d0ef04cae"

architecture=$(ynh_app_setting_get --app="$app" --key=architecture)

if [ "$architecture" = "x86-64" ]; then
	gitlab_source_sha256=$gitlab_x86_64_buster_source_sha256
elif [ "$architecture" = "arm64" ]; then
	gitlab_source_sha256=$gitlab_arm64_buster_source_sha256
elif [ "$architecture" = "arm" ]; then
	# If the version for arm doesn't exist, then use an older one
	if [ -z "$gitlab_arm_buster_source_sha256" ]; then
		gitlab_version="14.2.1"
		gitlab_arm_buster_source_sha256="f4553bb6a04fa580f2a4eb5ec5507701ae1c1cb4766cad58568d299d0ef04cae"
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
