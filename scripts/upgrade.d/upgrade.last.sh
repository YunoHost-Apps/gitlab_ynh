#!/bin/bash

gitlab_version="16.9.0"

# Upgrade path: https://gitlab-com.gitlab.io/support/toolbox/upgrade-path/
# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_bookworm_source_sha256="28afc81cc48b471362825204fcbb93a349da2239e3ac23af9e586280789b143a"
gitlab_x86_64_bullseye_source_sha256="5aee075e40252b725decf3ce244e243206a5d0d5a80828b1b3d520fddca6618f"
gitlab_x86_64_buster_source_sha256="882f060501ead0026d852eb6423f5526de5160d0bc1e0a2f1958a5997e282b71"

gitlab_arm64_bookworm_source_sha256="d2971257ce2d4b11a5bd17d5bdc97d37973f6fb88e437c882690097f8a2393e0"
gitlab_arm64_bullseye_source_sha256="313c609237839777241fa55b82cff18f46db0fd688b469952597c7132391aeb0"
gitlab_arm64_buster_source_sha256="0f2a691daed7f09dd022db7f75dd7e35c1b8dccfe78f2b143d9d5c419cfe0878"

gitlab_arm_bookworm_source_sha256=""
gitlab_arm_bullseye_source_sha256="66fdc13c2049cde394bf970b9bd2cb310199acc99ae24cd8dfe0629abaf94b41"
gitlab_arm_buster_source_sha256="3c984dec809ceff8ef24b6f397c89a2691063224ab55435066b4ddd3f24a94b4"

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
