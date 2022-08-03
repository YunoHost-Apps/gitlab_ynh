#!/bin/bash

gitlab_version="15.2.2"

# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_bullseye_source_sha256="d2a65650a15eb25c4a0c80e09db85edb31c99f54bdee751e6201c3977bd5058e"
gitlab_x86_64_buster_source_sha256="27b1e6ea735ea64cb534b25eb1ec2b0c672002e6fac84cf610a8b13f1573775a"

gitlab_arm64_bullseye_source_sha256="46f6623b254ef32ef051a472cd8718ceddf8d1a912f742a1c458aebdc513ccb1"
gitlab_arm64_buster_source_sha256="a60e28b94c3de9540e507fd4522580ff8bc0c17028f5f06cdf81dbf012115753"

gitlab_arm_buster_source_sha256="33147e1ee5281a5bf2f956b8237ee0a1352dab25f3931922e7e22f110884fa00"

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
elif [ "$architecture" = "arm" ]; then
	# If the version for arm doesn't exist, then use an older one
	if [ -z "$gitlab_arm_buster_source_sha256" ]; then
		gitlab_version="15.2.2"
		gitlab_arm_buster_source_sha256="33147e1ee5281a5bf2f956b8237ee0a1352dab25f3931922e7e22f110884fa00"
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
