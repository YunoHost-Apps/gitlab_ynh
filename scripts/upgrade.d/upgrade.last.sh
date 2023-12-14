#!/bin/bash

gitlab_version="16.6.2"

# Upgrade path: https://gitlab-com.gitlab.io/support/toolbox/upgrade-path/
# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_bookworm_source_sha256="8e0e621f0c18b534c945bf4781bbea6ac48f508be26716849a3846ea9d98f2c1"
gitlab_x86_64_bullseye_source_sha256="f8569113045c40f6b0dd444a0481b3fb3e9efb2220b500d630032bc9d5c174d2"
gitlab_x86_64_buster_source_sha256="9f7fdbee61d9036b1ed758babe1e4b16b25b6acee87b2fb9d0469e3862ab24a8"

gitlab_arm64_bookworm_source_sha256="2751902fd7c7771cc5be6c7ae20def7a24bd799da84932bba8dbdefcc0d17e06"
gitlab_arm64_bullseye_source_sha256="92ecf0f69c678aaba852981d39796dc4fcaa362898d5fda8cd1a6b7b87d8fd8e"
gitlab_arm64_buster_source_sha256="fcec664802fde786fe6cc4abd5c78ec9ec2ac005ebec111c3a8e9524dcfd4d56"

gitlab_arm_bookworm_source_sha256=""
gitlab_arm_bullseye_source_sha256="018d91e057703057522ab95307a08b0104e7c2060a5840889d1a938793c261ef"
gitlab_arm_buster_source_sha256="435988134187f1f3414b4badd33993ecad21ee5ebec16521388b8099940541ef"

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
