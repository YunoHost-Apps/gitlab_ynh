#!/bin/bash

gitlab_version="16.0.4"

# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_bullseye_source_sha256="2ea3897147e1d708ce5b510c81a9b74edbc843a2f3e7feb5ae60cf1c1de3c216"
gitlab_x86_64_buster_source_sha256="c12b356a159a7664cc648e2d521926d63026ee72d2bc9fe2354831b32e3ea2e1"

gitlab_arm64_bullseye_source_sha256="c485eb559ce6f2aa4629e2abb866995375703cfd16bd3bca48f975d1ffaec995"
gitlab_arm64_buster_source_sha256="36cee7603f28e13d01afd43c775b357bf5409dd648cf40ecfb1e3108fa0e3981"

gitlab_arm_buster_source_sha256="30d57db088c77a91a593766b223913fd9e4d7e6ce4974dc40b47124c571c0e74"
gitlab_arm_bullseye_source_sha256="4570f9799d0781a976c121439507fac06481bec9cf328513aac5875f64ad29d6"

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
			gitlab_version="16.0.4"
			gitlab_arm_buster_source_sha256="30d57db088c77a91a593766b223913fd9e4d7e6ce4974dc40b47124c571c0e74"
		fi
		gitlab_source_sha256=$gitlab_arm_buster_source_sha256
	elif [ "$gitlab_debian_version" = "buster" ]
	then
		# If the version for arm doesn't exist, then use an older one
		if [ -z "$gitlab_arm_bullseye_source_sha256" ]; then
			gitlab_version="16.0.4"
			gitlab_arm_bullseye_source_sha256="4570f9799d0781a976c121439507fac06481bec9cf328513aac5875f64ad29d6"
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
