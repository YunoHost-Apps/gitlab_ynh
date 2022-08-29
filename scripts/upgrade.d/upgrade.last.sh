#!/bin/bash

gitlab_version="15.3.1"

# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_bullseye_source_sha256="064da1aba682c3c5b8ee07eb171ea9e8e05ef1c74f166b533f6ef674cb4fd744"
gitlab_x86_64_buster_source_sha256="422f114a450b4b433c6036d45004c81184e511cfad4bbd21a30defb168a99edc"

gitlab_arm64_bullseye_source_sha256="40f62bb77d71128af94e6938832ade9d6d871c20062149df888e59ed7795015c"
gitlab_arm64_buster_source_sha256="4d2eff7c83d6d8d7d94f4b6eee451edcfafc14b00ba0753e51672dcd010aca00"

gitlab_arm_buster_source_sha256="3e7f51f7283d762f2ed834a1d94a2708cdb824782719d7b7e9ad2664089ccaf7"

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
		gitlab_version="15.3.1"
		gitlab_arm_buster_source_sha256="3e7f51f7283d762f2ed834a1d94a2708cdb824782719d7b7e9ad2664089ccaf7"
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
