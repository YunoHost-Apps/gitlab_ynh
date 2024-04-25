#!/bin/bash

gitlab_version="16.11.1"

# Upgrade path: https://gitlab-com.gitlab.io/support/toolbox/upgrade-path/
# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_bookworm_source_sha256="23fe5d12e90cfbdeadabfea85594497f1c3e44b7c49ae1541571f8f2556e74f3"
gitlab_x86_64_bullseye_source_sha256="3894448de581f9d77706c0ef95fc341d93b3d0882687f69557e8ff8a87e88a47"
gitlab_x86_64_buster_source_sha256="783ad4707bda7fdf21474aeaae9be81619b14aa90ee65768d3066847acd19a9b"

gitlab_arm64_bookworm_source_sha256="221ed443a50ade732df2ccf412aba4e46d65ca7108b93c88178ff77a827c82ef"
gitlab_arm64_bullseye_source_sha256="c0397400eae391921f457d37e2724c9ea465b2613cc950b6b68c633fef168f3a"
gitlab_arm64_buster_source_sha256="5fef5d810001807d2fca870e49b6e8e28b57ebd58e798680c7451dfbb9230920"

gitlab_arm_bookworm_source_sha256=""
gitlab_arm_bullseye_source_sha256="3500b408d5f69fdaae33d5e19f397495fd56c12616fa4286e2ddf0ccab208696"
gitlab_arm_buster_source_sha256="c37f95a5ce8522b4b8f9314fc83a5759d6c27e188ef1c0bc16ade573f3ced294"

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
