#!/bin/bash

gitlab_version="15.8.0"

# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_bullseye_source_sha256="5b24a53961f12fa68feb466d0106309a4e12719b25be1b7469dc66aefdfb8428"
gitlab_x86_64_buster_source_sha256="e9263e31eea55ee5011f82ad7e7c7fa1cc567bf07b0c02c1f1e8422a12e0deed"

gitlab_arm64_bullseye_source_sha256="ec4b52c756c7e46e36711edd7e889ed86b5eb1e6b5742dcfe4ef12bff2d1a43b"
gitlab_arm64_buster_source_sha256="048662441e22f3da0f970a4d2021847fa9540bc6fc5824a4d0c67453f547077f"

gitlab_arm_buster_source_sha256="854efbd055a23afa0c947c962b030ded3165d0a4af7ad84a0627a549160e3add"
gitlab_arm_bullseye_source_sha256="395cba0a44b6168b6834dff4defebfbd4a1f73a6e7e74e2a719514f3c30641ed"

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
			gitlab_version="15.8.0"
			gitlab_arm_buster_source_sha256="854efbd055a23afa0c947c962b030ded3165d0a4af7ad84a0627a549160e3add"
		fi
		gitlab_source_sha256=$gitlab_arm_buster_source_sha256
	elif [ "$gitlab_debian_version" = "buster" ]
	then
		# If the version for arm doesn't exist, then use an older one
		if [ -z "$gitlab_arm_bullseye_source_sha256" ]; then
			gitlab_version="15.8.0"
			gitlab_arm_bullseye_source_sha256="395cba0a44b6168b6834dff4defebfbd4a1f73a6e7e74e2a719514f3c30641ed"
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
