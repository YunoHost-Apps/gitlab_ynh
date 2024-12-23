#!/bin/bash

gitlab_version="17.5.4"

# Upgrade path: https://gitlab-com.gitlab.io/support/toolbox/upgrade-path/
# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_bookworm_source_sha256="cce9c2ae8151cca733c751b6a447d880ec2f03dfe8bab04a69883f8c69116209"
gitlab_x86_64_bullseye_source_sha256="c3266b2644acada39d77fe1033e7f2087ef68b3c539bf7560ed0b141299181be"
gitlab_x86_64_buster_source_sha256="f3c0aa923d36e647e4534a5b41e2e6df6925a1d9c31258edf274f82f6257eb49"

gitlab_arm64_bookworm_source_sha256="676eb4fdea04bc7d0412364b28c06ebbeec098687531d3b7935c30c59a8b8f3a"
gitlab_arm64_bullseye_source_sha256="2e3710c717d0487546c1ff09ac4149a7f201c4391b5f5d4b0787cdc629f24277"
gitlab_arm64_buster_source_sha256="b7746d13d75dc5137802f48e9c50cfc543f9668f49ba3738b69ca2dd7bed74b8"

gitlab_arm_bookworm_source_sha256="caa3aa61c8add54a17cd769006e8eda17b56900ab6f1b382571dfe7250955ad3"
gitlab_arm_bullseye_source_sha256="965290bad468e014e09671c5d05af6002234664fc79ea97cbbdd8338ddc9cb85"
gitlab_arm_buster_source_sha256="d810bc16eed5f1523409ac4a959f1ea1be267eabe0a4bdb54bd2a3994f391ad8"

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
