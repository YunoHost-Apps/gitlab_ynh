#!/bin/bash

gitlab_version="17.1.1"

# Upgrade path: https://gitlab-com.gitlab.io/support/toolbox/upgrade-path/
# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_bookworm_source_sha256="3473650c6c31c9db979f8e8992af22d39b888436a4bbb4e57d4939a3fd5bd27c"
gitlab_x86_64_bullseye_source_sha256="aa4d58f2610fae0ff74ae20fda3efa72bb0a93b641b349f3460295aaf8a5beb3"
gitlab_x86_64_buster_source_sha256="9041b06759acc9022c3e2863d5e8e67e29ce56b56a110b94bf02352a25ac72d2"

gitlab_arm64_bookworm_source_sha256="d8e7840465cf00e91ea49564e042b457a96e69b3141b40c8a772b6b895cd0382"
gitlab_arm64_bullseye_source_sha256="62aea1242324131d41b00aa34bd48b92a76bfa28172a970c69323ee8727c7fb7"
gitlab_arm64_buster_source_sha256="3a954b7a417c6329238b23bba0a9ab9c087b85b2dd46448b2187178678dd45b3"

gitlab_arm_bookworm_source_sha256=""
gitlab_arm_bullseye_source_sha256="63b11f5f5b69447acfc40cddaf7ee41c7d52b24cfabc782c096317595df06156"
gitlab_arm_buster_source_sha256="8dd975749d6a8d8ffb83c813ea57623e87bf9577025fbbcaab046dbd3394a534"

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
