#!/bin/bash

gitlab_version="14.2.2"

# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="buster"

gitlab_x86_64_buster_source_sha256="77de4f76b093c5a849def556c7fa8b9253efee340ad8a79fae2b5e20fd2b4b56"

gitlab_arm64_buster_source_sha256="a468eb0c9220cf7975fda0cecf949a9fad969c621b3408c01f79b4825ebfc0c1"

gitlab_arm_buster_source_sha256="06041dad5b4697384e6920a737a2b7ba1c730ef540941162075cc8c4c8e8ecff"

architecture=$(ynh_app_setting_get --app="$app" --key=architecture)

if [ "$architecture" = "x86-64" ]; then
	gitlab_source_sha256=$gitlab_x86_64_buster_source_sha256
elif [ "$architecture" = "arm64" ]; then
	gitlab_source_sha256=$gitlab_arm64_buster_source_sha256
elif [ "$architecture" = "arm" ]; then
	# If the version for arm doesn't exist, then use an older one
	if [ -z "$gitlab_arm_buster_source_sha256" ]; then
		gitlab_version="14.2.2"
		gitlab_arm_buster_source_sha256="06041dad5b4697384e6920a737a2b7ba1c730ef540941162075cc8c4c8e8ecff"
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
