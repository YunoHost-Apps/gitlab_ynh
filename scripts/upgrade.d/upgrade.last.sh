#!/bin/bash

gitlab_version="17.5.1"

# Upgrade path: https://gitlab-com.gitlab.io/support/toolbox/upgrade-path/
# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_bookworm_source_sha256="2d237f2eef74d00a3029f3c8aa70b038fd31dee297c9baa367064f44eff3f4ce"
gitlab_x86_64_bullseye_source_sha256="8abb7acb6914144c2e42cdce3017d871e02353e35839fea9da2ca27f764e1467"
gitlab_x86_64_buster_source_sha256="33199d136220a150106907d1eafef94bd042c14d849d5d5170c6660e3427b7a0"

gitlab_arm64_bookworm_source_sha256="5eeb955dfdc7b83571ff6fa16a2ff09da38be68ba6a3ba73f538bb91959d977e"
gitlab_arm64_bullseye_source_sha256="17d6b17dbe2bc2fe304883fb16d15b520441a3160faae4e853efeda046b13c00"
gitlab_arm64_buster_source_sha256="a80e4bf8f40b7e1714f02d7ddd9401e7371780ec6c6cb4ad12d856be47c070d5"

gitlab_arm_bookworm_source_sha256="9bf729ac933bb696c77be3fe4a681bc7464f10c5d1447501ed3cd972faf586b0"
gitlab_arm_bullseye_source_sha256="727cf0bb7c2069570a881619de592dca2a46d61db875e004aec7cb1fdaf465d8"
gitlab_arm_buster_source_sha256="b3e5623eef418c3f0402ebf938717e9b0ae5185a319c6e7bfdb35935a76b1395"

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
