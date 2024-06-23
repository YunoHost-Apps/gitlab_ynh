#!/bin/bash

gitlab_version="16.11.4"

# Upgrade path: https://gitlab-com.gitlab.io/support/toolbox/upgrade-path/
# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_bookworm_source_sha256="bb832ba67d86e111e616f933a1a8cc81ffa8ce973d47ebf3c793ceaf9696edb4"
gitlab_x86_64_bullseye_source_sha256="2d5aa60b882d97d0be17c35ac86dbc4d5dc3c51adc099fa70de5da3f6dbc9603"
gitlab_x86_64_buster_source_sha256="9aaccc3aee94a9ec4fa55c3d09d4e5dcf744fed0555b242c4bda9600314272d5"

gitlab_arm64_bookworm_source_sha256="2cb858e73dedaa212e05939bad187fe6d3caedf7f984c39665064fe7db4818c2"
gitlab_arm64_bullseye_source_sha256="c4eda7e8b5dfcf48fb31226c917664d4b39f2747f551813f0243bfb123a69ff5"
gitlab_arm64_buster_source_sha256="fe09d913344e88626341a4870cf60e30b550fa80e44eb2b9c106ff56c8817423"

gitlab_arm_bookworm_source_sha256=""
gitlab_arm_bullseye_source_sha256="203fb855056b4e2b5a252dc3b3c6667294347d4cb44de8b4c7f0ee15de83a1bf"
gitlab_arm_buster_source_sha256="2553fcfa670a185330cb26633bd0bdc3fbe15f9a0a4ad4fe203c4b465577b80b"

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
