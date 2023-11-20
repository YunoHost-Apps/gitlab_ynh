#!/bin/bash

gitlab_version="16.6.0"

# Upgrade path: https://gitlab-com.gitlab.io/support/toolbox/upgrade-path/
# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_bookworm_source_sha256="ffd9cfd4682ca7e39ffbadb068e39a3c4435fa4afb335403619288d63a6a31f2"
gitlab_x86_64_bullseye_source_sha256="3f4d6db09e40cb62380223fbe21f2ac134e9b3ea8ac848e3faa637e5e1d4aef5"
gitlab_x86_64_buster_source_sha256="292a64f985e0420785bb34307a585c41fce27096d3c78a07a568a41c2a307dde"

gitlab_arm64_bookworm_source_sha256="20f1e6a6af09197d80abc29d2079c56ce620724f2c999ff882d074f51e624ba3"
gitlab_arm64_bullseye_source_sha256="bec1ee9f9b5166c4fada35805b99b3c8ad243be29ce97d83269bf843da4fdf95"
gitlab_arm64_buster_source_sha256="993b49ff213e850111ba4102e4304027dfb6feea31d40a8658361b08d0d22d4d"

gitlab_arm_bookworm_source_sha256=""
gitlab_arm_bullseye_source_sha256="c7bd4eaae53cd09acafa756a92e88c2729ae023b690fc165c19650bb03b21c37"
gitlab_arm_buster_source_sha256="73ed6e2885dcefefdcea8773479082a8c25b64546fb800b2934f396ed58c8368"

architecture=$(ynh_app_setting_get --app="$app" --key=architecture)

# Evaluating indirect/reference variables https://mywiki.wooledge.org/BashFAQ/006#Indirection 
# ref=gitlab_${architecture}_${gitlab_debian_version}_source_sha256
# gitlab_source_sha256=${!ref}

if [ "$architecture" = "x86-64" ]; then
	if [ "$gitlab_debian_version" = "bookworm" ]
	then
		gitlab_source_sha256=$gitlab_x86_64_bookworm_source_sha256
	elif [ "$gitlab_debian_version" = "bullseye" ]
	then
		gitlab_source_sha256=$gitlab_x86_64_bullseye_source_sha256
	elif [ "$gitlab_debian_version" = "buster" ]
	then
		gitlab_source_sha256=$gitlab_x86_64_buster_source_sha256
	fi
elif [ "$architecture" = "arm64" ]; then
	if [ "$gitlab_debian_version" = "bookworm" ]
	then
		gitlab_source_sha256=$gitlab_arm64_bookworm_source_sha256
	elif [ "$gitlab_debian_version" = "bullseye" ]
	then
		gitlab_source_sha256=$gitlab_arm64_bullseye_source_sha256
	elif [ "$gitlab_debian_version" = "buster" ]
	then
		gitlab_source_sha256=$gitlab_arm64_buster_source_sha256
	fi
elif [ "$architecture" = "arm" ]; then
	if [ "$gitlab_debian_version" = "bookworm" ]
	then
		gitlab_source_sha256=$gitlab_arm_bookworm_source_sha256
		if [ -z "$gitlab_arm_bookworm_source_sha256" ]
		then
			gitlab_source_sha256=$gitlab_arm_bullseye_source_sha256
		fi
	elif [ "$gitlab_debian_version" = "bullseye" ]
	then
		gitlab_source_sha256=$gitlab_arm_bullseye_source_sha256
	elif [ "$gitlab_debian_version" = "buster" ]
	then
		gitlab_source_sha256=$gitlab_arm_buster_source_sha256
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
