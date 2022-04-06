#!/bin/bash

gitlab_version="14.9.2"

# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_bullseye_source_sha256="4a9b94edcd97f09198aeb8f64d973f0a892f6554d18afedf688ae9d1ca21e9b3"
gitlab_x86_64_buster_source_sha256="f51e05dd6d352a5b5c13e174ddf70c71c60109140b9274b77ae63c61eb701611"

gitlab_arm64_bullseye_source_sha256="7826fad61eae70138ff06a33b3471466a11c5237c0960daecde1b94a3e694265"
gitlab_arm64_buster_source_sha256="6b4493b2d55ad6cd796036324dd1953e58ecb7ccf80dc4d02f5a4dbf0d56c8b8"

gitlab_arm_buster_source_sha256="38033ef2cfcf23e466795a3630645a45cbc1ca771d4273e29398ec7641255ef1"

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
	# If the version for arm doesn't exist, then use an older one
	if [ -z "$gitlab_arm_buster_source_sha256" ]; then
		gitlab_version="14.9.2"
		gitlab_arm_buster_source_sha256="38033ef2cfcf23e466795a3630645a45cbc1ca771d4273e29398ec7641255ef1"
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
