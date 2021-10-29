#!/bin/bash

gitlab_version="14.4.0"

# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="buster"

gitlab_x86_64_buster_source_sha256="89d12148595ac1e5e127ec96ed877e738c28e5eed02328d26b1610341c291d92"

gitlab_arm64_buster_source_sha256="98ec153767bf80c55e12be896f2005658e91ed761715841fbf87bfb41953f961"

gitlab_arm_buster_source_sha256="e950b5f4fa76d051eddd20ae9cd1aab017f9b0abee41be1fee566ed0b39146ea"

architecture=$(ynh_app_setting_get --app="$app" --key=architecture)

if [ "$architecture" = "x86-64" ]; then
	gitlab_source_sha256=$gitlab_x86_64_buster_source_sha256
elif [ "$architecture" = "arm64" ]; then
	gitlab_source_sha256=$gitlab_arm64_buster_source_sha256
elif [ "$architecture" = "arm" ]; then
	# If the version for arm doesn't exist, then use an older one
	if [ -z "$gitlab_arm_buster_source_sha256" ]; then
		gitlab_version="14.4.0"
		gitlab_arm_buster_source_sha256="e950b5f4fa76d051eddd20ae9cd1aab017f9b0abee41be1fee566ed0b39146ea"
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
