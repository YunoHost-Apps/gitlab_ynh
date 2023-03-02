#!/bin/bash

gitlab_version="15.9.1"

# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_bullseye_source_sha256="d5ad1cdbbe0f1528f9fc1354aaf62458fad148a3e43999e708b4b3e3ed922560"
gitlab_x86_64_buster_source_sha256="e3f3bc4f434f5036236c0eeeb33a58bc87d64a625a4592fb4c22bbadcc0499ee"

gitlab_arm64_bullseye_source_sha256="10c8935db7f66929e809b52a2b354d3d5b01034ed596a0379add13b7e75e5ed7"
gitlab_arm64_buster_source_sha256="b521658326b24b1b647fedd18028253f96d264b48a6faf1a313b75925890f6d6"

gitlab_arm_buster_source_sha256="e90e6b0ad4f619040f7e518a83ca4bbcdf373665edbe1edfbe13320de44f54f0"
gitlab_arm_bullseye_source_sha256="b59b524b602da091a6b5a989349c7895c468f9083584192fce1056e9cb164d4b"

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
			gitlab_version="15.9.1"
			gitlab_arm_buster_source_sha256="e90e6b0ad4f619040f7e518a83ca4bbcdf373665edbe1edfbe13320de44f54f0"
		fi
		gitlab_source_sha256=$gitlab_arm_buster_source_sha256
	elif [ "$gitlab_debian_version" = "buster" ]
	then
		# If the version for arm doesn't exist, then use an older one
		if [ -z "$gitlab_arm_bullseye_source_sha256" ]; then
			gitlab_version="15.9.1"
			gitlab_arm_bullseye_source_sha256="b59b524b602da091a6b5a989349c7895c468f9083584192fce1056e9cb164d4b"
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
