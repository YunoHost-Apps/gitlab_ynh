#!/bin/bash

gitlab_version="17.3.6"

# Upgrade path: https://gitlab-com.gitlab.io/support/toolbox/upgrade-path/
# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_bookworm_source_sha256="4fe43d03fa7fbe14873a1b6cce44a862d9146db149a243bd8fbaa80146af25f4"
gitlab_x86_64_bullseye_source_sha256="02197635515294a9b24c79307028884917297290ddb997ec0fa294974489958f"
gitlab_x86_64_buster_source_sha256="604091d1df018db15aded8120f336b1c7db2cdf9b28414197c71b2d92b3bdf28"

gitlab_arm64_bookworm_source_sha256="bf48dedffa30d4e5a6a28d85879a4a6040c9c3af5e6838f744b3a9fddd6c7289"
gitlab_arm64_bullseye_source_sha256="328cb7108d105fd6d803b478e8e0cae7c27e840584ef63c10c20d170aa1b5928"
gitlab_arm64_buster_source_sha256="cbbde34813a9c5a9ac6e23a50572aed02d0075a96d420fbd4a52afd6af578cab"

gitlab_arm_bookworm_source_sha256="2b32ad869af52abda473598432f5d400d8b85e9d3444de59e5bf9c85c420d33b"
gitlab_arm_bullseye_source_sha256="0e0487189b2e7964bad4d4f91ca160ae81cffb3b4beb2df9156607043db15664"
gitlab_arm_buster_source_sha256="dd45486747ff9ad51e26f6aadf658ad79dc813a2272743e8b54828cf76d0fa48"

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
