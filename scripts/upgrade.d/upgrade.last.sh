#!/bin/bash

gitlab_version="17.4.0"

# Upgrade path: https://gitlab-com.gitlab.io/support/toolbox/upgrade-path/
# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_bookworm_source_sha256="4871e1091f58424e6d4a5d3497fa831803126998e5fce8fecedcad78d955caa8"
gitlab_x86_64_bullseye_source_sha256="8f033a3cefe9d00588fd57ace665948e9b18bc2dd64d29d4ca25a971704d67c9"
gitlab_x86_64_buster_source_sha256="a6d77fbe98593da9fb33795c68751ab6a541096be9480245ac4e822cd68219df"

gitlab_arm64_bookworm_source_sha256="707c5f89caa79173a269a2734aaae392214a6bbd27ffadfc9f4275a308c679bd"
gitlab_arm64_bullseye_source_sha256="95b1e14a9ece18d13b55dcd9aac7bb2d2fe33b6d158d7dc2cdd0ee45d6fd1831"
gitlab_arm64_buster_source_sha256="f9cc69001429ceedfdc5c0c6e124594c3dcb331def850245fd6d2d3a96b3b862"

gitlab_arm_bookworm_source_sha256="f8af3203cee3f668f4d95b1d1742216cf7a8d799e91e6e32476e96e45a48d022"
gitlab_arm_bullseye_source_sha256="e0871826bc01bb8276dac00f46d07d1938bdb0277868c2bcc348543cd454d839"
gitlab_arm_buster_source_sha256="733442a54b408a27eab07dad3b81fd770b694d02b5bfda5e7b7df19c2c07012e"

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
