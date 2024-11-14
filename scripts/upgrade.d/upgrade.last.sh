#!/bin/bash

gitlab_version="17.5.2"

# Upgrade path: https://gitlab-com.gitlab.io/support/toolbox/upgrade-path/
# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_bookworm_source_sha256="93071122d7d559c6372770d41626e2d03b3af4be5651a3cb669505cd6d8a3b00"
gitlab_x86_64_bullseye_source_sha256="4d98e59751a323067345e6adbbe9ce6472acb1f670f09b30fc3aa6be21f1ae4a"
gitlab_x86_64_buster_source_sha256="239d800894a1d447142be53babc25c480ce9ed0048376b71a9b973c8add1c651"

gitlab_arm64_bookworm_source_sha256="ba319f7a8c2ac117bf3ea781a4bd49e86f420ded66ffd553e074016a8d9e13f1"
gitlab_arm64_bullseye_source_sha256="cec95e0dcbf342bbd66bf64d46fad2df02dcc7ac704e8715f80026d178b33dbd"
gitlab_arm64_buster_source_sha256="513f576deb53a2a96455bceed5e05cf646fda3ee04220e4c2ea6dcaca1d0886a"

gitlab_arm_bookworm_source_sha256="5f2e559f70d99cb1e8c7ec7b57d20e8b7a79e94d73d5315c6a9d448423e8d2de"
gitlab_arm_bullseye_source_sha256="952fc4d0abbe5e1a697fbdab7f287c2613f3f35879b07cf24099a5edf4394470"
gitlab_arm_buster_source_sha256="6cfbec4a328ff4d7db23608eab2feaff6289a978b9775eb0bbd6e77775fc508b"

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
