#!/bin/bash

gitlab_version="14.0.4"

# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="buster"

gitlab_x86_64_buster_source_sha256="110157284f221cd0881be3ff13698d29e4ab7727dd2d6db61f1d85e446b4527f"

gitlab_arm64_buster_source_sha256="7aded3999c34ed7927e63da481a09179488647735c235927bb6193af0aa77131"

gitlab_arm_buster_source_sha256=""

architecture=$(ynh_app_setting_get --app="$app" --key=architecture)

if [ "$architecture" = "x86-64" ]; then
	gitlab_source_sha256=$gitlab_x86_64_buster_source_sha256
elif [ "$architecture" = "arm64" ]; then
	gitlab_source_sha256=$gitlab_arm64_buster_source_sha256
elif [ "$architecture" = "arm" ]; then
	# If the version for arm doesn't exist, then use an older one
	if [ -z "$gitlab_arm_buster_source_sha256" ]; then
		gitlab_version="14.0.0"
		gitlab_arm_buster_source_sha256="3b52c9d414974b2c6c639f881e2c736c9790eac16fcb070ce82bcce52b8958a2"
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
