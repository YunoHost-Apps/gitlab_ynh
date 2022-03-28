#!/bin/bash

gitlab_version="14.9.1"

# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_bullseye_source_sha256="c5945ec778701ed1f29d663527929102c17527e75e0a07804c2d58ae74d0786e"
gitlab_x86_64_buster_source_sha256="d1546e23522690b3f314e1edbb165d24684dd70de2c6e075a040d02b5e48dfb2"

gitlab_arm64_bullseye_source_sha256="6e0a03d5aa85797610ca1eea24f2bbe1c974f61e04673ad00391c7dedd236ae7"
gitlab_arm64_buster_source_sha256="f883acc3fdad0cf27080a247abd94891724d452f8e75e9f1b19a07121af702b3"

gitlab_arm_buster_source_sha256="c8fcc05aa2ede0556798b732dd823c8d7f8b153a7c6683cc2f619f014429679e"

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
	gitlab_source_sha256=$gitlab_arm64_buster_source_sha256
elif [ "$architecture" = "arm" ]; then
	# If the version for arm doesn't exist, then use an older one
	if [ -z "$gitlab_arm_buster_source_sha256" ]; then
		gitlab_version="14.9.1"
		gitlab_arm_buster_source_sha256="c8fcc05aa2ede0556798b732dd823c8d7f8b153a7c6683cc2f619f014429679e"
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
