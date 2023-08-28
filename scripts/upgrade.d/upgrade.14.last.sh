#!/bin/bash

gitlab_version="14.10.5"

# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_bullseye_source_sha256="75a4a53afe53e8c0286523b2067c79da629b14afd1142ae5ed838945a80530e5"
gitlab_x86_64_buster_source_sha256="1462b565780412f9f5776ac85cf2e07fe31d94af156a9232abfad280b1162dbc"

gitlab_arm64_bullseye_source_sha256="03148ca8b71505545be74cc2aed14f2f252eadfb7c7a2c30f4da9d650f5e8fc8"
gitlab_arm64_buster_source_sha256="bbb08026c00c00d6f8f797e15cc8b9d29baaab66d6ddf5642689b3321ed4a8c3"

gitlab_arm_buster_source_sha256="24a1c3089bc2836591a153a38a04ae8e0f8807d7e877e5d7fa64987f84699d56"

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
