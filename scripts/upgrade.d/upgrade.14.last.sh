#!/bin/bash

gitlab_version="14.10.4"

# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_bullseye_source_sha256="a026d0bace56bf2cbe6ae6f60d998dba183e9d6606f158df8ebf2da727fa53ee"
gitlab_x86_64_buster_source_sha256="c4c06776ad990c2112ef095454c8a5edfc89e29ca0eef1f7f9f4cfa375fcb266"

gitlab_arm64_bullseye_source_sha256="7eb714f383d7dd933590cf45829e135500643ed93dbea720ae4f3a49197c9cdf"
gitlab_arm64_buster_source_sha256="586cc2af4cfc49f94003234d061ac7c4472f547ef3ab9ad9073cfbe519acc97e"

gitlab_arm_buster_source_sha256="f3f6b21bdcda6035c8ec3b8baf64dc07a48f96ea42c0f411b077a657baf1bba9"

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
		gitlab_version="14.10.4"
		gitlab_arm_buster_source_sha256="f3f6b21bdcda6035c8ec3b8baf64dc07a48f96ea42c0f411b077a657baf1bba9"
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
