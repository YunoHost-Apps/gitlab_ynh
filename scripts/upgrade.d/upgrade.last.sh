#!/bin/bash

gitlab_version="16.4.0"

# Upgrade path: https://gitlab-com.gitlab.io/support/toolbox/upgrade-path/
# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_bookworm_source_sha256="f026ded6507866a8ef8ba22f6644ad183f83a435f4f9a798c7a6d57fb687330c"
gitlab_x86_64_bullseye_source_sha256="5fa3c5fa19d055f46a44d8f12e128315c758488971d11f9a89600ecba4ce9676"
gitlab_x86_64_buster_source_sha256="8b3850d09bb0e5c025c3048e344dabe739153e49a5f42946eb66d0f7de73686f"

gitlab_arm64_bookworm_source_sha256="85c56255204603cbd7286b41f21e0c1109375bb9ada8034009039ae3885e5b6c"
gitlab_arm64_bullseye_source_sha256="e5451d13632b142f582c68a82324941dff1a9fecedab4da0862d07b058dfb2f3"
gitlab_arm64_buster_source_sha256="60431671af22bc492d367a24089d17a864833bad464ab200156363e096716a95"

gitlab_arm_bookworm_source_sha256=""
gitlab_arm_bullseye_source_sha256="cbba55eba613e4496580e127fcc37ba4d5034be0b3cc53136c718e3c469d772b"
gitlab_arm_buster_source_sha256="1739f29fdd49ef1805e567f4c967b28f98e7ce849b673fc1aac61200bee02a64"

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
