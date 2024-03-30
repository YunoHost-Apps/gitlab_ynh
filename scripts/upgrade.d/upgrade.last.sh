#!/bin/bash

gitlab_version="16.10.1"

# Upgrade path: https://gitlab-com.gitlab.io/support/toolbox/upgrade-path/
# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_bookworm_source_sha256="e0b7b087c586b91bd2e67b0c119159df170e1a856f88249ec64b85b5e0c76077"
gitlab_x86_64_bullseye_source_sha256="d5b06da77a8523971c1d3ce8dfad6dd4d6d1e5df72798e17e185ce45bfd73ac5"
gitlab_x86_64_buster_source_sha256="3f99f993f489c10f6d4a327b7875f7716d67c4059d4cbcaf6426fd7d3fd4138d"

gitlab_arm64_bookworm_source_sha256="dfb2858b3ea1e048c7a9342e18f4a862df5d065a4c1ff88e706b243eaaaca3ae"
gitlab_arm64_bullseye_source_sha256="2da4b82eb9f7d8f37149192c66ad7013940724d8eb8e993a3072516f288f085b"
gitlab_arm64_buster_source_sha256="0bf354f2ea1f61a3cd13a0e146ba67ffb96311cb65efa03415e1dbca64f29b53"

gitlab_arm_bookworm_source_sha256=""
gitlab_arm_bullseye_source_sha256="bfeb3ba3c3d089c6ecfcfafc57e77b89e3413b86c8c1e2516d806b1a34e288ba"
gitlab_arm_buster_source_sha256="210b8c5728fcf7c434e72b9dec38a8c4f61a3d3589ca96494e625ef5716595e3"

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
