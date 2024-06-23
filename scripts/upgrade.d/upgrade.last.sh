#!/bin/bash

gitlab_version="17.1.0"

# Upgrade path: https://gitlab-com.gitlab.io/support/toolbox/upgrade-path/
# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_bookworm_source_sha256="69a57e488fe82afccdbe95753299ff479d38d23ee91c8aba3d9ef3e1ee783262"
gitlab_x86_64_bullseye_source_sha256="c85ce193c1b5b90588506b51872391b97a2c342a7143335adeb3958d08a3c342"
gitlab_x86_64_buster_source_sha256="be5ff642253c817bfccccf6545f8550de24106c9ae9e3e600f11d8dfc6982199"

gitlab_arm64_bookworm_source_sha256="e8c3f62cdce151e9ca0e33a2125d330dc0fee8fe87932118b95ca6950d3349ae"
gitlab_arm64_bullseye_source_sha256="85193e62e2850638a26b339c001da1ee73f063d653ae8d9c3db2f74fee295a1a"
gitlab_arm64_buster_source_sha256="a41bc4334f21659eb331939a63e54358f9bb27d156f4b286e68729567e63b622"

gitlab_arm_bookworm_source_sha256=""
gitlab_arm_bullseye_source_sha256="7d117dee3ba272e8ee607fd351ee7b714eb4c479ca8c08818404373d4a19a11e"
gitlab_arm_buster_source_sha256="971255f63407de4a9bae34b7985b2b98b4995a1373215ffedf1e265912e900bc"

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
