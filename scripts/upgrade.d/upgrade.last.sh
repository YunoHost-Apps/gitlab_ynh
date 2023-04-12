#!/bin/bash

gitlab_version="15.10.2"

# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_bullseye_source_sha256="ca165fd01cfbb3159b3e741b318cfa6365a3840d8d813538fee61f623594b0b4"
gitlab_x86_64_buster_source_sha256="2ec4c085ab48faa1f8a9fe334c01eaa63d75277fb1a35605a9d31259a3c074e1"

gitlab_arm64_bullseye_source_sha256="faeb39eed99b68409f5a518307791ac85e0a00f497b0616b0d16ad50b644d826"
gitlab_arm64_buster_source_sha256="6dd3920f929c15613d8013b1b184b6c3c9c291bfff735b0636007ccc25d34b65"

gitlab_arm_buster_source_sha256="ab1b8c5414b6f02205978d282b4db8acddc34379e19800d409bf5b69fe9f0ccd"
gitlab_arm_bullseye_source_sha256="4a26d508f5791497fc8a191c142e3725a7c04b4cc1fbfaf7033a706880298aa2"

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
		# If the version for arm doesn't exist, then use an older one
		if [ -z "$gitlab_arm_buster_source_sha256" ]; then
			gitlab_version="15.10.2"
			gitlab_arm_buster_source_sha256="ab1b8c5414b6f02205978d282b4db8acddc34379e19800d409bf5b69fe9f0ccd"
		fi
		gitlab_source_sha256=$gitlab_arm_buster_source_sha256
	elif [ "$gitlab_debian_version" = "buster" ]
	then
		# If the version for arm doesn't exist, then use an older one
		if [ -z "$gitlab_arm_bullseye_source_sha256" ]; then
			gitlab_version="15.10.2"
			gitlab_arm_bullseye_source_sha256="4a26d508f5791497fc8a191c142e3725a7c04b4cc1fbfaf7033a706880298aa2"
		fi
		gitlab_source_sha256=$gitlab_arm_bullseye_source_sha256
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
