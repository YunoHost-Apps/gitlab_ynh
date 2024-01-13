#!/bin/bash

gitlab_version="16.7.3"

# Upgrade path: https://gitlab-com.gitlab.io/support/toolbox/upgrade-path/
# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_bookworm_source_sha256="7e1683956b2e33f17ce4be3f0d5e5751d915fc92a5a0554bbf257ad2a21963a0"
gitlab_x86_64_bullseye_source_sha256="22fe358741c994259bb6edc693d6ee273320543fc0fc81a0f231295aea8aa4c9"
gitlab_x86_64_buster_source_sha256="d6e48115716c664c9c56a683499d8697f015b07443f5a4e1256ece3c73e4d4c2"

gitlab_arm64_bookworm_source_sha256="df267bb8820370a730a3977711744384271f870e18fd5a1c82fa8faa78e9cb36"
gitlab_arm64_bullseye_source_sha256="1f3116e27d59614f382aab847ddedae99bed82216cd92112ad71315a8a713d79"
gitlab_arm64_buster_source_sha256="ddf5aabe2b25830f7bb6f1715b73cad39e60837397cf8439d133503e8f20946e"

gitlab_arm_bookworm_source_sha256=""
gitlab_arm_bullseye_source_sha256="cb771cec30ff09fd7260748c37e878485bc67d95dbe52183664850fb5544771a"
gitlab_arm_buster_source_sha256="5bdec83f9f8e2b0d1ed16eeb9811a882e7e82659c5f4694e071971a909f8be8e"

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
