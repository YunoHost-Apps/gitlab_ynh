#!/bin/bash

gitlab_version="15.8.3"

# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_bullseye_source_sha256="51f80218b21a074991eaa73d33f6a731f30851ade555f6e2446b452b3248612d"
gitlab_x86_64_buster_source_sha256="13776b70a58a39bed2795415c28ff7354a287ac7103178816a50680e933dbc8e"

gitlab_arm64_bullseye_source_sha256="5ef36081b15732a8b49f1f8120d513c652eef6c5d77418bad82ebe3f1e72c6f7"
gitlab_arm64_buster_source_sha256="a9cfafa3a906e6d6e4d7923d9331b6d971129fc247142ab9c9d1cc9a5f0db982"

gitlab_arm_buster_source_sha256="e92988ba6f860202a2bce0f529db2e1ba1f180dcc951e679001b9142d0d29e98"
gitlab_arm_bullseye_source_sha256="839680fafe0be6dbd9333c914cad38a4d8ff8b16b4b6922de551cc073e4c8147"

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
			gitlab_version="15.8.3"
			gitlab_arm_buster_source_sha256="e92988ba6f860202a2bce0f529db2e1ba1f180dcc951e679001b9142d0d29e98"
		fi
		gitlab_source_sha256=$gitlab_arm_buster_source_sha256
	elif [ "$gitlab_debian_version" = "buster" ]
	then
		# If the version for arm doesn't exist, then use an older one
		if [ -z "$gitlab_arm_bullseye_source_sha256" ]; then
			gitlab_version="15.8.3"
			gitlab_arm_bullseye_source_sha256="839680fafe0be6dbd9333c914cad38a4d8ff8b16b4b6922de551cc073e4c8147"
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
