#!/bin/bash

gitlab_version="17.6.1"

# Upgrade path: https://gitlab-com.gitlab.io/support/toolbox/upgrade-path/
# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_bookworm_source_sha256="6a7a7c5388fbf96333e1934e191d23c116c727c5bc0a47c7a432563442a7efd1"
gitlab_x86_64_bullseye_source_sha256="8e37b5ba22d86e7d066e9fc984460d71f9560c5907799e1d06c9030de316aa81"

gitlab_arm64_bookworm_source_sha256="dbb7dfa4194eeaed0039d6bb8613a2557ee622c94c8fb9a988fdc9fbf702e653"
gitlab_arm64_bullseye_source_sha256="f2a44624b8e75a5dbe1464f6a7f3323ea755480d9681547bb921febd01eaf029"

gitlab_arm_bookworm_source_sha256="e9f9592123602e7864b6aa164c27cc2d9a23288e0897b1f5ddc811f2d50cd9b2"
gitlab_arm_bullseye_source_sha256="3c267ce185b7b9a96fbf2aedbdd96a9fde23ea7187cb99b6cdc3ad4ca52957f3"
gitlab_arm_buster_source_sha256="dc5051a10bc9ee2d1277cda59084af25bdd12eb74997820cac658b2403ad519e"

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
	fi
elif [ "$architecture" = "arm64" ]; then
	if [ "$gitlab_debian_version" = "bookworm" ]
	then
		gitlab_source_sha256=$gitlab_arm64_bookworm_source_sha256
	elif [ "$gitlab_debian_version" = "bullseye" ]
	then
		gitlab_source_sha256=$gitlab_arm64_bullseye_source_sha256
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
