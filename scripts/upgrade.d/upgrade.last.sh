#!/bin/bash

gitlab_version="17.2.1"

# Upgrade path: https://gitlab-com.gitlab.io/support/toolbox/upgrade-path/
# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_bookworm_source_sha256="3f6eda84728380787bff751b76cb5ddaffe7f07376ba873de8e33865fc5b671e"
gitlab_x86_64_bullseye_source_sha256="6a82c30d61683ae51cc7442d45d5dcb880ea9343857cf3c59a3aa52fa964eb57"
gitlab_x86_64_buster_source_sha256="0f89798b7df3a904d454238926d1accf9b71b543f2b8c7113d42061bcf342a13"

gitlab_arm64_bookworm_source_sha256="39ca066d25ca23642bb7d6e1a6df4dcfeefa6638a3e33127b2969b243984eb13"
gitlab_arm64_bullseye_source_sha256="cc7b86ca2fd3b72c8f14c57d5b4742b82fc7db24de217c1072076218654bca5f"
gitlab_arm64_buster_source_sha256="fc6893c6c545551886db6800f85dd2bd7c135e5a09fdd78d86305b90a4f67fd1"

gitlab_arm_bookworm_source_sha256=""
gitlab_arm_bullseye_source_sha256="cd3d23bca99147a47485e061c04b28fc8784db05cadccb1d044ba2e95a13dd55"
gitlab_arm_buster_source_sha256="d1cc0e2327a3ebd9a08adec1f3d3ab3b48daf2c0eb61fb737635130e94e3bce7"

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
