#!/bin/bash

gitlab_version="17.3.7"

# Upgrade path: https://gitlab-com.gitlab.io/support/toolbox/upgrade-path/
# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_bookworm_source_sha256="26ad3fd4533e648d8a0e393ef95c761da486aca6d84295c8ba99d0ee6afa989e"
gitlab_x86_64_bullseye_source_sha256="e78c276952c6202c23b9baac8afe05ebcaf1c5f2639e51865157e5ebddbb9554"
gitlab_x86_64_buster_source_sha256="44c7f77c33eb40543f1ebf68c42b07d643e1492399a9afc375018d5742834697"

gitlab_arm64_bookworm_source_sha256="7fc3fc2b589f7f270f04d03bf0286d0b271f33346f521dc1174ced9d9b4d2561"
gitlab_arm64_bullseye_source_sha256="f22a39ea10275d7be6b0abe02728ae92f99afdcce2220d1d6cf802332375b1f8"
gitlab_arm64_buster_source_sha256="9a886b7f5a910ac95ce2b391504f23ddab15718656486ce0e76960609e5b3d4b"

gitlab_arm_bookworm_source_sha256="97c6132b062a0cef707d0dc74bb67bc16eccc345bfce96d3513188fc5bdcc092"
gitlab_arm_bullseye_source_sha256="3917ab066b55bdf3c4d3cf1dec3e91ed86d2d3cff3fcf570c4a553c405051d5e"
gitlab_arm_buster_source_sha256="ae49a4136afa6fc321a40c2dca79e8e4ac4daf85ef6f4f90de7fadd0e004e28c"

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
