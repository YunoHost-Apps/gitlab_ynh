#!/bin/bash

gitlab_version="16.1.1"

# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_bookworm_source_sha256="93a347b794b54b9aeead46a1cd7ff03fbdad6a41f75679e584091d5dcc1e9bff"
gitlab_x86_64_bullseye_source_sha256="8314b2d0029769cce1f24fa775d7680c49f88fc5c53176e24f699828d1cb1647"
gitlab_x86_64_buster_source_sha256="74592bfba421cced9911b0373fcc1f12639b283dd822b076d300e90c419f7bfb"

gitlab_arm64_bookworm_source_sha256="de1449f54ecec2ed2f1f6321c539e6d848faaf0ba6734c23ac1c20c657e642a5"
gitlab_arm64_bullseye_source_sha256="adff825941e91a0421fffc491e1e3d2632e5a210fd66320e304c850d07f73ed4"
gitlab_arm64_buster_source_sha256="a7a5e0228d6fb23919679af7548ba1255e785f4a7fe7e5926545a2a254577980"

gitlab_arm_bookworm_source_sha256=""
gitlab_arm_bullseye_source_sha256="5aa71840a808f99f27afb9bf89deb73bda9185e1f91a1f1796f21e5bba8ac104"
gitlab_arm_buster_source_sha256="4a2e40b602797121780676197570093814d035281034ff30f08060255969bdb8"

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
