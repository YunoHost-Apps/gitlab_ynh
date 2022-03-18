#!/bin/bash

gitlab_version="14.8.3"

# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_bullseye_source_sha256="948adb94af48fc6100cf2d0e9015f31e02cfbbd2c0a57457e13b80ea711428ff"
gitlab_x86_64_buster_source_sha256="1f76f7e55dfc05a5bfa4db0ffac9c0ef1cb51e85ccb95e096cfb46594bc04919"

gitlab_arm64_bullseye_source_sha256="ec0af5697f0c8607d3af9073cc605d4c29e0a6ca9458d53e7842408eb4df1369"
gitlab_arm64_buster_source_sha256="8b1fb75525b94c2670393676279860d7a64a365d1ce4e69b21bbd50579141f39"

gitlab_arm_buster_source_sha256="1bc0b92ec8bb97cf21d4437ba23c4e0568b7f60eb301f34c53f1ab620774c736"

architecture=$(ynh_app_setting_get --app="$app" --key=architecture)

if [ "$architecture" = "x86-64" ]; then
	if [ "$gitlab_debian_version" = "bullseye" ]
	then
		gitlab_source_sha256=$gitlab_x86_64_bullseye_source_sha256
	elif [ "$gitlab_debian_version" = "buster" ]
	then
		gitlab_source_sha256=$gitlab_x86_64_buster_source_sha256
	fi
elif [ "$architecture" = "arm64" ]; then
	if [ "$gitlab_debian_version" = "bullseye" ]
	then
		gitlab_source_sha256=$gitlab_arm64_bullseye_source_sha256
	elif [ "$gitlab_debian_version" = "buster" ]
	then
		gitlab_source_sha256=$gitlab_arm64_buster_source_sha256
	fi
	gitlab_source_sha256=$gitlab_arm64_buster_source_sha256
elif [ "$architecture" = "arm" ]; then
	# If the version for arm doesn't exist, then use an older one
	if [ -z "$gitlab_arm_buster_source_sha256" ]; then
		gitlab_version="14.8.3"
		gitlab_arm_buster_source_sha256="1bc0b92ec8bb97cf21d4437ba23c4e0568b7f60eb301f34c53f1ab620774c736"
	fi
	gitlab_source_sha256=$gitlab_arm_buster_source_sha256
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
