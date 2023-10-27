#!/bin/bash

gitlab_version="16.5.0"

# Upgrade path: https://gitlab-com.gitlab.io/support/toolbox/upgrade-path/
# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_bookworm_source_sha256="5d91d00aff827350ea36a86779753617d52d0edc402ae955bdf41d95942a1e60"
gitlab_x86_64_bullseye_source_sha256="b62f152992892fc6324821ee2058e1363c3decab4910eaa99574575fd47f6fdb"
gitlab_x86_64_buster_source_sha256="24eb4db9e044b4cc44b5b16b3d4cd97a600212eeee5eedb2ea1f86728df96cc2"

gitlab_arm64_bookworm_source_sha256="9f8837e3970165c87cc373bb90fc4833131e492af80c035ac3b4aab04903e56a"
gitlab_arm64_bullseye_source_sha256="1b428c362e20ecd35525f3c1a86525a9d960204fc8732c602ea5a43be657cbd7"
gitlab_arm64_buster_source_sha256="f009f6f23c56b028f0d653d28baf849a5770419c17c189d59827edd71f5a18ed"

gitlab_arm_bookworm_source_sha256=""
gitlab_arm_bullseye_source_sha256="552c65f1f41c632d3675c495136c028f9b9ca4b75374525d74f2b6aa7e47596d"
gitlab_arm_buster_source_sha256="47cc1a152c8a86cf225eed75337d349cd31738efd92d2c8c1fa5c96fd47df08f"

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
