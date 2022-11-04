#!/bin/bash

gitlab_version="15.5.2"

# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_bullseye_source_sha256="22031a4bb2ae8e84591d0d148b7e48f78aca46d13dfa93c6dac3476b9444643e"
gitlab_x86_64_buster_source_sha256="1d36367e8e1424514ef09cefefcce65183e923d6ace9e9432cafd9bfa581eb54"

gitlab_arm64_bullseye_source_sha256="ca35a8750ae390a535de834a9e01ecff66ff4ed8534bce1053c54e1d0dc0f29d"
gitlab_arm64_buster_source_sha256="b791885b296d8476ce85246ea45aeeff51c891afa5d1138ccb338722eee8dcfa"

gitlab_arm_buster_source_sha256="673edcaee9d861b7b6540cbdfad3a35861d2cc095b3b8e33e962c291c69f97bd"
gitlab_arm_bullseye_source_sha256="282d24a8405ea84e20985c136bffa8ed18975c5b81231c7e086ccc726a946ab4"

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
	if [ "$gitlab_debian_version" = "bullseye" ]
	then
		# If the version for arm doesn't exist, then use an older one
		if [ -z "$gitlab_arm_buster_source_sha256" ]; then
			gitlab_version="15.5.2"
			gitlab_arm_buster_source_sha256="673edcaee9d861b7b6540cbdfad3a35861d2cc095b3b8e33e962c291c69f97bd"
		fi
		gitlab_source_sha256=$gitlab_arm_buster_source_sha256
	elif [ "$gitlab_debian_version" = "buster" ]
	then
		# If the version for arm doesn't exist, then use an older one
		if [ -z "$gitlab_arm_bullseye_source_sha256" ]; then
			gitlab_version="15.5.2"
			gitlab_arm_bullseye_source_sha256="282d24a8405ea84e20985c136bffa8ed18975c5b81231c7e086ccc726a946ab4"
		fi
		gitlab_source_sha256=$gitlab_arm_bullseye_source_sha256
	fi
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
