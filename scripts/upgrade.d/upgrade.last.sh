#!/bin/bash

gitlab_version="16.8.1"

# Upgrade path: https://gitlab-com.gitlab.io/support/toolbox/upgrade-path/
# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_bookworm_source_sha256="119cb1a085202257fbf2d6ae1e8b5d27f2dafbf1b1abcfeb1011e854f0964043"
gitlab_x86_64_bullseye_source_sha256="56ec42ca2e0a7ed45507c8f870be9a80fdabb98702da8cd0c81f0c261fa6147b"
gitlab_x86_64_buster_source_sha256="5e13d37cbcce2be6359a94a483b063bacf88ed745fd7edc3973f066a48009a11"

gitlab_arm64_bookworm_source_sha256="eb95af3527fad21bc4536a2703dc039c5c9e9d8b24a6cfd4f6d310b6498ebae2"
gitlab_arm64_bullseye_source_sha256="c21c03856b04ebdd6552b2a7865786dd7fa6789c99d1106fbfad960fdd0338ec"
gitlab_arm64_buster_source_sha256="ab0c167dfa89e5bfe86e303462a5c579d60421a0ad4e13675068ae0a6fa78223"

gitlab_arm_bookworm_source_sha256=""
gitlab_arm_bullseye_source_sha256="3ff3715f56bda621d31adc2cb0883323e8ca2494a7de627188a6ed3a9bee7573"
gitlab_arm_buster_source_sha256="79a1fb41072cc3793dec637185375f722298f7254b44d0048e1f8fbad2343670"

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
