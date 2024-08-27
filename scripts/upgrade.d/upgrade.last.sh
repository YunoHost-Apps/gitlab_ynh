#!/bin/bash

gitlab_version="17.3.1"

# Upgrade path: https://gitlab-com.gitlab.io/support/toolbox/upgrade-path/
# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_bookworm_source_sha256="62fa53982c28d97d06bf5d472503a75239b71a5084a04899026fe30d94072777"
gitlab_x86_64_bullseye_source_sha256="6e6136eb00fcc63e60af460b332fe9d65c7ecb37e87fd98c2881584206f34f1f"
gitlab_x86_64_buster_source_sha256="68448990a6d12fcd6c24ab22626907cbe17b02f58bc62db8d20759d2193f2a4c"

gitlab_arm64_bookworm_source_sha256="4bb5ba840b53deb9f3779b4ebfbb177852a0bddca8cc0f462b3746a213e3b8bc"
gitlab_arm64_bullseye_source_sha256="a147cbc7339b5f050b5e4a9d3f5bf34eb783313c65dd6c43a813397be58908e0"
gitlab_arm64_buster_source_sha256="868a9e57b39bbb6644afb155ae8bda756bc7381c6ad46821c2c596b3ffe763c3"

gitlab_arm_bookworm_source_sha256="8cd646aa3b8e207559e48904c84792d22d0964524652a8211870845561fe4bd0"
gitlab_arm_bullseye_source_sha256="242bf38fa03de6b3f96e92c578a2a23f8eedc45bf2eefe995b8328c82ebb9151"
gitlab_arm_buster_source_sha256="2e70c86e5b9197ccb57d475521a95511ca35340e5dc1d0d3a67cfe9a959202ad"

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
