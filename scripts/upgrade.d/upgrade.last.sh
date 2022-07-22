#!/bin/bash

gitlab_version="15.2.0"

# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_bullseye_source_sha256="6389276f340fc7992030e9da6d8689bbc064413344b3336b2c00e2082ec3ec70"
gitlab_x86_64_buster_source_sha256="6288ca86bdfcf0300a22025fd804ec4a0360a0cbfe8f82a90c510589d5effa5b"

gitlab_arm64_bullseye_source_sha256="5a43d9fe8d6ecb22af5bea15f29fca6c20d81c3795bc6e5999f8e37ae80c69a5"
gitlab_arm64_buster_source_sha256="8b904fe231a6a10a8991be32202c06e2446dd112b7d97a08f7aa1d24573c168b"

gitlab_arm_buster_source_sha256="549250a4515b2f634132f5769fafc747c938995445f2738da511d55827572d61"

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
		gitlab_version="15.2.0"
		gitlab_arm_buster_source_sha256="549250a4515b2f634132f5769fafc747c938995445f2738da511d55827572d61"
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
