#!/bin/bash

gitlab_version="16.3.7"

# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_bullseye_source_sha256="4e702837d3e2add5a129ffb11828b53e17cbe4d8f1d33f748de52f869ec0d142"
gitlab_x86_64_buster_source_sha256="21e18b883189b670ab1c67cc5cc9b238ad1b101e0caed2618183f440e795dff6"

gitlab_arm64_bullseye_source_sha256="9189a30575b2d5a51a2304307c46eb4e5924cec1fbe0344b24715eae417976b7"
gitlab_arm64_buster_source_sha256="d4197c6b76141939d2cfa7770f1723203564debd31b366762fc125d92babb2f2"

gitlab_arm_buster_source_sha256="57d0934b4c603aac247a013fa4226a362684c8e7e9595359e6c858bf2f461443"
gitlab_arm_bullseye_source_sha256="b311a008bae9a4ff23568bac847bf0e4571d201bc65ff305d58e7121b5bebd49"

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
elif [ "$architecture" = "arm" ]; then
	if [ "$gitlab_debian_version" = "bullseye" ]
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
