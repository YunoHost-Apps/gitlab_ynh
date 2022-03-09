#!/bin/bash

gitlab_version="14.8.1"

# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_bullseye_source_sha256="e544887406a79d4f3545eb8b84c3c9fa2a0c016481ee33d6a1db84561aff8b65"
gitlab_x86_64_buster_source_sha256="b89d8fa4a31703377951de663b73062ac22f213c9ec1fe2821027558ad496265"

gitlab_arm64_bullseye_source_sha256="c1163c372b0a2bfa61e5275a75df46ef7c365b737a37227a79df2a64bad3ad17"
gitlab_arm64_buster_source_sha256="7c5e2e4d3a784888d3aba2a30e49b7d55a1ada77ae3e4ee1619f8d1e792fe7e0"

gitlab_arm_buster_source_sha256="c744081368656d6a76b48fc148a528b32b08facc58b74748ef1e301878b08f47"

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
		gitlab_version="14.8.1"
		gitlab_arm_buster_source_sha256="c744081368656d6a76b48fc148a528b32b08facc58b74748ef1e301878b08f47"
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
