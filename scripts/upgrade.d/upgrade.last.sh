#!/bin/bash

gitlab_version="14.2.3"

# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="buster"

gitlab_x86_64_buster_source_sha256="c83a3f9d73e4b2178b13a856aa41bd7eea5319c0bddec4cc50f29e294e02adda"

gitlab_arm64_buster_source_sha256="b5980a570c62943b744ec71e5124e3efd88418331edc4f2dde4a14bcefa8b52e"

gitlab_arm_buster_source_sha256="323e9c182a95c3f67335907426dc9e917f8a065b4da4014053a84c85b190ee8f"

architecture=$(ynh_app_setting_get --app="$app" --key=architecture)

if [ "$architecture" = "x86-64" ]; then
	gitlab_source_sha256=$gitlab_x86_64_buster_source_sha256
elif [ "$architecture" = "arm64" ]; then
	gitlab_source_sha256=$gitlab_arm64_buster_source_sha256
elif [ "$architecture" = "arm" ]; then
	# If the version for arm doesn't exist, then use an older one
	if [ -z "$gitlab_arm_buster_source_sha256" ]; then
		gitlab_version="14.2.3"
		gitlab_arm_buster_source_sha256="323e9c182a95c3f67335907426dc9e917f8a065b4da4014053a84c85b190ee8f"
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
