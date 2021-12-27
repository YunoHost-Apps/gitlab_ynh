#!/bin/bash

gitlab_version="14.6.0"

# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_bullseye_source_sha256="d58b5f7dc1a435d57d74e8540c2c646c12b708085b2aa077fbdfb14eff13b629"
gitlab_x86_64_buster_source_sha256="2321f763edd9142a018e20e5029289528ef84769f20b8077acc85e6712aafb12"

gitlab_arm64_bullseye_source_sha256="2502431a6edd723a6c3bdcc3243961aaeb3f4225c2e5a7ea3b9251489496b517"
gitlab_arm64_buster_source_sha256="8a0da4655f67f205d265eba205b3913bc07bc47d95a3f8e882024839c461cadc"

gitlab_arm_buster_source_sha256="0548d379352465793f0c201f745486bf9c88d9952073a8fd46b005bf62f71c68"

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
		gitlab_version="14.6.0"
		gitlab_arm_buster_source_sha256="0548d379352465793f0c201f745486bf9c88d9952073a8fd46b005bf62f71c68"
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
