#!/bin/bash

gitlab_version="15.5.0"

# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_bullseye_source_sha256="f57dd7f7c63fc94f6a45053c764175da99dd9c1f4e6774335ed718619e078c6a"
gitlab_x86_64_buster_source_sha256="448842802c14d8361b209c9dca2181cf02a6fea5a93b20568d69d207566c5b23"

gitlab_arm64_bullseye_source_sha256="85e0fb93d0cc6d11cbbcfa43753ffbc12c30324acf587384312c43636668f374"
gitlab_arm64_buster_source_sha256="626916f28fb439fd9a9a45eee2ce8ca9b0ee46b424223f0386f0fb255409f638"

gitlab_arm_buster_source_sha256="72b8f4efbd7ca83456dbf1cb84e9244d8d58ddfc6ea31347301366f3139b6aab"
gitlab_arm_bullseye_source_sha256="4a67e72e423ca2de5497017ef2746db054df93d0230c82e04ed01bd29b58c028"

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
			gitlab_version="15.5.0"
			gitlab_arm_buster_source_sha256="72b8f4efbd7ca83456dbf1cb84e9244d8d58ddfc6ea31347301366f3139b6aab"
		fi
		gitlab_source_sha256=$gitlab_arm_buster_source_sha256
	elif [ "$gitlab_debian_version" = "buster" ]
	then
		# If the version for arm doesn't exist, then use an older one
		if [ -z "$gitlab_arm_bullseye_source_sha256" ]; then
			gitlab_version="15.5.0"
			gitlab_arm_bullseye_source_sha256="4a67e72e423ca2de5497017ef2746db054df93d0230c82e04ed01bd29b58c028"
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
