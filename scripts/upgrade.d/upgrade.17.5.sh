#!/bin/bash

gitlab_version="17.5.3"

# Upgrade path: https://gitlab-com.gitlab.io/support/toolbox/upgrade-path/
# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_bookworm_source_sha256="79313e9338f534027208c750532f91376584afb54c47136d8be185360a419047"
gitlab_x86_64_bullseye_source_sha256="f376d7c385e40ea2d0f858a686967db638e480f49cb7a3ad442bc3e2ba2403f7"
gitlab_x86_64_buster_source_sha256="c241ecaf892a03d0b366ccdb16af564e890693827e19288ece2ad11727e4ace1"

gitlab_arm64_bookworm_source_sha256="8b69d1c362a392f159cba7be6ef6722ccd2bd250bd5ad2ab495490226aa0cf0b"
gitlab_arm64_bullseye_source_sha256="6b010c3f4f814b5fed6d135990f9394cb8e4ec203e43ed3951fcba0ffee5f546"
gitlab_arm64_buster_source_sha256="2d20ee42e981161fb0a9a3a0f24dcce3f7b24e39343613f7d78abadce3323892"

gitlab_arm_bookworm_source_sha256="1c27db14da70e5a2b21789ce6e4f46cb59ce913554d6e9fe6b70cca6fc9744fe"
gitlab_arm_bullseye_source_sha256="964cca958e199fb77ff6b237418e83ce66f586057d16aa34facd72b58b6166ea"
gitlab_arm_buster_source_sha256="f4d31aecb1184c836da9f5f68a4b17c52736bf02c39ee2b948356f4a33481645"

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
