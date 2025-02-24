#!/bin/bash

gitlab_version="17.5.5"

# Upgrade path: https://gitlab-com.gitlab.io/support/toolbox/upgrade-path/
# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_bookworm_source_sha256="cce4ebff28a0b76152922b09a2cb67fd4bc0cfdff22185654135bb93ce658bcf"
gitlab_x86_64_bullseye_source_sha256="b0f40eb8a2d55634cff59125304df1fa1fda1601dec1bf3547a4351aabd81221"
gitlab_x86_64_buster_source_sha256="30bcadafe193fdc670f024e1a527dd3a632f57173757d75120ae75c82b347dc9"

gitlab_arm64_bookworm_source_sha256="51c8ca34a1c2d24b209b74f6f5dbf4e446d61cbe85de51f56c010e116c2468b3"
gitlab_arm64_bullseye_source_sha256="8b9e8722e064889f9e20f781e61356ce8035cec5fe4cbe255b6aba97e7a7067c"
gitlab_arm64_buster_source_sha256="db83b6e3b9689f9d584cb57a2c40a77deef8dfb0a638981af5fc8993f744720b"

gitlab_arm_bookworm_source_sha256="a2b443f777030cc8dd9e1bd63879ac2d27091c7f91b2191b4504cda35efe8e30"
gitlab_arm_bullseye_source_sha256="44183f66b822afabc5948065eb335d5ae5376811b48847614246ccec99638481"
gitlab_arm_buster_source_sha256="3b4b4bfdfcfb65dc971c8ed6b89afa58303c129839f33d804a968ea60c19b91f"

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
