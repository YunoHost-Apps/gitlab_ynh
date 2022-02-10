#!/bin/bash

gitlab_version="14.7.2"

# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_bullseye_source_sha256="2610800719b7426ac397861abaa4c3e9d8bfa51d6ca63fb725d72f8f86d58de0"
gitlab_x86_64_buster_source_sha256="b44ae9cb5f053a3af864c3de57278c188eac02bf2e412b0f0c1c14b1c7b2448f"

gitlab_arm64_bullseye_source_sha256="240a57a7086ade09244f260943baa2306784cdee71b0271ac13b15f451f5c78e"
gitlab_arm64_buster_source_sha256="772d873ab223c466c07777a21cc6518a1d9ee3425a7dbbda6336a03e77ac4615"

gitlab_arm_buster_source_sha256="f2d8c6b9b7eeff8c45564d7f47e1d8f4e1838cd381e51277ba523f5d9d068f8f"

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
		gitlab_version="14.7.2"
		gitlab_arm_buster_source_sha256="f2d8c6b9b7eeff8c45564d7f47e1d8f4e1838cd381e51277ba523f5d9d068f8f"
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
