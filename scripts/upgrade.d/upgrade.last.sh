#!/bin/bash

gitlab_version="16.2.1"

# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_bookworm_source_sha256="1bfab0d0cf06fbc14a800bda404c5280f9ba6ce5206600ff1f3deb9cb38cb529"
gitlab_x86_64_bullseye_source_sha256="515b7baf0777b669fc38cdd1e7241ef570995d3c70ef0eafea71d7a2fe230c19"
gitlab_x86_64_buster_source_sha256="fc9da9ef2e135fbccffa8eb1b6110ea4d13fc838914b4dc9c0e74737e41a2e55"

gitlab_arm64_bookworm_source_sha256="9e4b8f8a4647d035a570794829d6f9c56e8af37cd9ae9e98b34a1c73fdc04a9e"
gitlab_arm64_bullseye_source_sha256="2bd247f74012006779b306969f0ee84f3215f8eeb2d374a57973548063eb5235"
gitlab_arm64_buster_source_sha256="15b74c0e0e9c25bf2874fd2ff616e155d8cf3b42d9a98a77474ba25b8d2661ae"

gitlab_arm_bookworm_source_sha256=""
gitlab_arm_bullseye_source_sha256="15f31f35db3a5290b520b69e46f824e0b4a0ea4753e1b3ebc98b944e2079263c"
gitlab_arm_buster_source_sha256="d3a023869fe62345e5c0f4f7c2de3c42c3bbba92193a7094ee7291c12b1f9b06"

architecture=$(ynh_app_setting_get --app="$app" --key=architecture)

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
