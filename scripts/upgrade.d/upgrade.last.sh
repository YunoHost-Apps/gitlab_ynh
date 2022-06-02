#!/bin/bash

gitlab_version="15.0.1"

# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_bullseye_source_sha256="ee9f23d438469f932234712256ad7e858b1c688976b65ef4003beb77e7cafb34"
gitlab_x86_64_buster_source_sha256="c30134cbe7045d08b78230b81ac7671295a058462de4f42d37c801ce49454a36"

gitlab_arm64_bullseye_source_sha256="a152319d9bd0b932d643d9c1494ec0f69db26ead43c7d384f970d4215d21a0de"
gitlab_arm64_buster_source_sha256="94e6a4c0c571b9e54405fcc0fa67cbdbc1a4600ccf92f5fda6ad4602dd35a22d"

gitlab_arm_buster_source_sha256="7a3d0743383914ba29ade230f897e25a4fa70ce766e8eb4de7a449017e11474d"

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
		gitlab_version="15.0.1"
		gitlab_arm_buster_source_sha256="7a3d0743383914ba29ade230f897e25a4fa70ce766e8eb4de7a449017e11474d"
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
