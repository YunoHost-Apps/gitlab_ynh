#!/bin/bash

gitlab_version="16.4.1"

# Upgrade path: https://gitlab-com.gitlab.io/support/toolbox/upgrade-path/
# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_bookworm_source_sha256="df3b33056545cf5fe4924bfd0095a6522ef71eee625e9401d44501f305c9c5a9"
gitlab_x86_64_bullseye_source_sha256="7dd3d47f77f349497ef93f686686c3a778e318393ec2917775faa6fe1afb650e"
gitlab_x86_64_buster_source_sha256="83ac8ea1fc5e9e85e9da10860a7fbd43da80754f74dce3b7323ac65a846907fb"

gitlab_arm64_bookworm_source_sha256="de2119bd329c1e62565e73471075303ff08e1632375f3e4e9b7930552f19ff2e"
gitlab_arm64_bullseye_source_sha256="dc981cb85db2b2661a18dc55611bedede4df0b7b3699195723fd0fbb3ada47b8"
gitlab_arm64_buster_source_sha256="2ccb99c2ed16121730735a037d288ec3d72385151a0461c2b9893ec458d1310a"

gitlab_arm_bookworm_source_sha256=""
gitlab_arm_bullseye_source_sha256="e86dbe38bae3488f40ea6c1d2405ba632af687b1d410902d6fe1c4a6e943883f"
gitlab_arm_buster_source_sha256="f59e68495d2916992e3f91216f38d489367abb2061fad22a38d9b4ecc969a7aa"

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
