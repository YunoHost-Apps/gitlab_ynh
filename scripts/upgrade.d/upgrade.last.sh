#!/bin/bash

gitlab_version="14.9.0"

# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_bullseye_source_sha256="1ee36b1e74d424f2ef7cdb7de98e5b322afea3a674e801d5fbf670f5377add63"
gitlab_x86_64_buster_source_sha256="f01412a7c385cba3ed92689f9165f0e72aa13b33d9a802f09e55336e426f4f7c"

gitlab_arm64_bullseye_source_sha256="a849ce359fda7e19adaa4302ba92a3dd566f384bb6b81f6ebc919787299ce33d"
gitlab_arm64_buster_source_sha256="e77e89ee193a13d50e0e6400f586b1ec86afc8a43e7d5e00242aa70d86ec278b"

gitlab_arm_buster_source_sha256="d913d4835c10d569c5298cc3d6bf765b0c83b6d08be6646a89a8850579456a71"

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
		gitlab_version="14.9.0"
		gitlab_arm_buster_source_sha256="d913d4835c10d569c5298cc3d6bf765b0c83b6d08be6646a89a8850579456a71"
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
