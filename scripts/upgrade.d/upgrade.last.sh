#!/bin/bash

gitlab_version="16.9.1"

# Upgrade path: https://gitlab-com.gitlab.io/support/toolbox/upgrade-path/
# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_bookworm_source_sha256="40d2fa21eb01d07e937436938725ab6c16b8ba95fd193189f7bdd3e5c88175de"
gitlab_x86_64_bullseye_source_sha256="ef4225677c2b650a748a7b42a564091178dfa5e7c5f0a2d300468a0c160d7461"
gitlab_x86_64_buster_source_sha256="24d6676130a48bb747f2abfe53bd51f59102e1997796a1e14492e72643a12f99"

gitlab_arm64_bookworm_source_sha256="996c59e2c924bdf45d712be5edc6a3d8fc330df8d7dd5492641348321216ee88"
gitlab_arm64_bullseye_source_sha256="ee1651d37e4d524cd36127844d1cf83bed7675841c07c9f03f24bad27d4932cd"
gitlab_arm64_buster_source_sha256="1f47cb6eaea6c4b2c1280e898710b621fbd7618564f4c50f7c1ee5123787ec07"

gitlab_arm_bookworm_source_sha256=""
gitlab_arm_bullseye_source_sha256="ca592a4b000571bd5de6aeed95a2abf067127bd303c46c6fd8757f42dc3bc477"
gitlab_arm_buster_source_sha256="be180053b3b1a43308eac14e837faa65bcea909cef10a4c3b66f989fcfeff5f5"

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
