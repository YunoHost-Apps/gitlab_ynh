#!/bin/bash

gitlab_version="14.7.0"

# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_bullseye_source_sha256="1a6546698a696c108ba7389d6618883e3271867d5a791c9589d8d7317f1786dd"
gitlab_x86_64_buster_source_sha256="86a358afd842378f1f026141d318595dfad40e79e2096f776f2ff3d189329fd7"

gitlab_arm64_bullseye_source_sha256="3205a39d830e2e18d08d25bc247e9315f3b0c429bfa08fa4f5be79e869ef650e"
gitlab_arm64_buster_source_sha256="b4df358d6b25ffec2b6a714714e08ae44949b4fae748875fc46e5fd3ddef1d65"

gitlab_arm_buster_source_sha256="c6aca4d4d15fada15c3dc818685194ba1239c5a80bafbcdd64ffea532c92e745"

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
		gitlab_version="14.7.0"
		gitlab_arm_buster_source_sha256="c6aca4d4d15fada15c3dc818685194ba1239c5a80bafbcdd64ffea532c92e745"
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
