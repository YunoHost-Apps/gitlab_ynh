#!/bin/bash

gitlab_version="16.2.4"

# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_bookworm_source_sha256="61ed818dc013289379298d7e73c6aa19869cac7072599370ea9315fe81d3c87a"
gitlab_x86_64_bullseye_source_sha256="9fa5ab656a95b5d9666af3747e8ea90bc51e935da2f31d9d03b516f833a74730"
gitlab_x86_64_buster_source_sha256="bc8851cdf4c912f83af7de4f0413f965f26e0f98a98ec2ea04f5dc9b71be977b"

gitlab_arm64_bookworm_source_sha256="f13220dfa473185996fa265244ebdf6d7b6bc8b0e61aa4a15d0edc3300e04e20"
gitlab_arm64_bullseye_source_sha256="dbb79862f79f7611d074ef194d6c96254a94e0b7f739732ea7c1e16c264c36b4"
gitlab_arm64_buster_source_sha256="cdba0c8be878594356954f53fc26a084dcb409b3a775c88ec9811605f23f23fe"

gitlab_arm_bookworm_source_sha256=""
gitlab_arm_bullseye_source_sha256="053a89316fef0f5e91d91cd9b5872b24fbda9716e26ebbfdb0a2cf6d23d930ba"
gitlab_arm_buster_source_sha256="b09ef8072f80458f7ac6aec7e7c2b5d1193e75df5eeef18c0e4728a11ba6fb17"

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
