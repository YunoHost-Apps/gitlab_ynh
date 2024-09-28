#!/bin/bash

gitlab_version="17.4.1"

# Upgrade path: https://gitlab-com.gitlab.io/support/toolbox/upgrade-path/
# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_bookworm_source_sha256="20a65148644cb3ab51a5d7720612abe0dd5ba067744d7d7080cbeb46e3ba11a1"
gitlab_x86_64_bullseye_source_sha256="c54c9a31dfe009eb597600a5c15376291942cad2f0dc6a0a70a28f005ff4dfe8"
gitlab_x86_64_buster_source_sha256="cf33d495344a4f054c0054b67e6c6a80b21966f711a973c0db46aedf7a725643"

gitlab_arm64_bookworm_source_sha256="ed14e569c19fc63bf6abddc87716550cb62eed25923c7599254c2c8487d344ad"
gitlab_arm64_bullseye_source_sha256="695476d6982b4d6b834b061f6eb5eefbadcba2a791da11c502c31b7d9a6d94ad"
gitlab_arm64_buster_source_sha256="ad885e8a2aa74643792751dae8f545b670682f13a26f1a1e1ac29ec83dc124d1"

gitlab_arm_bookworm_source_sha256="12a0700f9cb9267b339aa307ad294a8e78940bbd8396e32432a96fd8afeb0b39"
gitlab_arm_bullseye_source_sha256="67f86137dfc604e4910071c4b9808dec2d967f0791d1767ce5b99deaf1f49215"
gitlab_arm_buster_source_sha256="d74262e2eb508d7065c99bad1a16a6e4a859d6b683696a8a7b3727b3f4b93fad"

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
