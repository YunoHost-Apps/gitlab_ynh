#!/bin/bash

gitlab_version="17.1.8"

# Upgrade path: https://gitlab-com.gitlab.io/support/toolbox/upgrade-path/
# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_bookworm_source_sha256="6a0c4466d43692491d3bd63a66f411ede7114ed73cc0d71649c0def1d1768e6b"
gitlab_x86_64_bullseye_source_sha256="4aeefcae5fc886a83a5bca02f96b9ea15390d19f3dd5e60f43971d8e373830b3"
gitlab_x86_64_buster_source_sha256="a7b89de5a29370d67d37e1ae1a0756c6fa6d6fb0b457f778c206d4818caa3824"

gitlab_arm64_bookworm_source_sha256="64d92f60b00079f40f62dd5248e1bc6a1da0938b0e6fb22c921c4907e93b8b9c"
gitlab_arm64_bullseye_source_sha256="fbbcad2475101deb46c2bdba3cf5cac01ac0816b23f0e1dea682912ce85d5b30"
gitlab_arm64_buster_source_sha256="6a828fac7e8685dceb0f9c469bfa341fc51fcdadf3b2f7467657aaf091c1ca4d"

gitlab_arm_bookworm_source_sha256=""
gitlab_arm_bullseye_source_sha256="3788e4e70dd4b69b8bc39dc4c533189ae094a8491323f17c4cd4b8be42dfd7b6"
gitlab_arm_buster_source_sha256="90c63f1ebaf3c28fe841e060873c452cab7150758e1e85785d09a53198b8c644"

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
