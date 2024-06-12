#!/bin/bash

gitlab_version="17.0.2"

# Upgrade path: https://gitlab-com.gitlab.io/support/toolbox/upgrade-path/
# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_bookworm_source_sha256="447d32a4ee2fb278037f141eb5f2c2e4f9d5958c0e7b7101c7adb9f82c8b7635"
gitlab_x86_64_bullseye_source_sha256="df2eab15f094e30570da37914eb5b59478591684d1fd85d7f515e7834a9198b1"
gitlab_x86_64_buster_source_sha256="24863dd68cf6cf93b4b84dbc2f7b9662681c172b839f7fde30af1df2a1aac21f"

gitlab_arm64_bookworm_source_sha256="d61abb2956b6c546fb0399c1ef8b0a040303ede9184f4553a7a8b2e4bc2b2188"
gitlab_arm64_bullseye_source_sha256="5ed91c06407090c5a961599b08ed8d7078cf3df971483c3c4702e298b12feaec"
gitlab_arm64_buster_source_sha256="127a53b317b03b523078c140023065a15c5d6f730478f7b1f49c280859576beb"

gitlab_arm_bookworm_source_sha256=""
gitlab_arm_bullseye_source_sha256="cffd318fce3bb73855f05d1761d79c49d21b1cf049ec2c16fc176d3b9d04ba4f"
gitlab_arm_buster_source_sha256="787b26de09953df417a4233cdd25879cc45a85cdff46ec92d301a660dd4776cb"

architecture=$(ynh_app_setting_get --app="$app" --key=architecture)

# Evaluating indirect/reference variables https://mywiki.wooledge.org/BashFAQ/006#Indirection 
# ref=gitlab_${architecture}_${gitlab_debian_version}_source_sha256
# gitlab_source_sha256=${!ref}

if [ "$architecture" = "x86-64" ]; then
	if [ "$gitlab_debian_version" = "bookworm" ]
	then
		gitlab_source_sha256=$gitlab_x86_64_bookworm_source_sha256
	elif [ "$gitlab_debian_version" = "bullseye" ]
	then
		gitlab_source_sha256=$gitlab_x86_64_bullseye_source_sha256
	elif [ "$gitlab_debian_version" = "buster" ]
	then
		gitlab_source_sha256=$gitlab_x86_64_buster_source_sha256
	fi
elif [ "$architecture" = "arm64" ]; then
	if [ "$gitlab_debian_version" = "bookworm" ]
	then
		gitlab_source_sha256=$gitlab_arm64_bookworm_source_sha256
	elif [ "$gitlab_debian_version" = "bullseye" ]
	then
		gitlab_source_sha256=$gitlab_arm64_bullseye_source_sha256
	elif [ "$gitlab_debian_version" = "buster" ]
	then
		gitlab_source_sha256=$gitlab_arm64_buster_source_sha256
	fi
elif [ "$architecture" = "arm" ]; then
	if [ "$gitlab_debian_version" = "bookworm" ]
	then
		gitlab_source_sha256=$gitlab_arm_bookworm_source_sha256
		if [ -z "$gitlab_arm_bookworm_source_sha256" ]
		then
			gitlab_source_sha256=$gitlab_arm_bullseye_source_sha256
		fi
	elif [ "$gitlab_debian_version" = "bullseye" ]
	then
		gitlab_source_sha256=$gitlab_arm_bullseye_source_sha256
	elif [ "$gitlab_debian_version" = "buster" ]
	then
		gitlab_source_sha256=$gitlab_arm_buster_source_sha256
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
