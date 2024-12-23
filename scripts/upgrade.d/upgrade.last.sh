#!/bin/bash

gitlab_version="17.7.0"

# Upgrade path: https://gitlab-com.gitlab.io/support/toolbox/upgrade-path/
# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_bookworm_source_sha256="04f821bfeae14ab3efc85dde499c52cebd2a924ab064af44c48f2d644e85c3b8"
gitlab_x86_64_bullseye_source_sha256="7c299bc2d58d45b11722cbfd9e5e7a00a97c537c6f236b9e5a546862b3f8c6f5"

gitlab_arm64_bookworm_source_sha256="9157e42d403dd445dd8f9669fe5a7ef5b419c6bbd4366f1135e1170d5d551c45"
gitlab_arm64_bullseye_source_sha256="2fccc6bf67c06dcb348a27b655f8fa831d95827ceb9eba4280a1ad3eff82b0cc"

gitlab_arm_bookworm_source_sha256="0b28782705b6e7141ce3817166c7ac1fe16878bdba1de550f3def899d3bc4b26"
gitlab_arm_bullseye_source_sha256="9f9614c48432bc20d0b005f608c04478ccd3213164e10b411ef71cd3444a5a5f"
gitlab_arm_buster_source_sha256="f7adf5327305db16a79f6cff7d812e5c621a735558d3e016761f393be2de92bc"

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
	fi
elif [ "$architecture" = "arm64" ]; then
	if [ "$gitlab_debian_version" = "bookworm" ]
	then
		gitlab_source_sha256=$gitlab_arm64_bookworm_source_sha256
	elif [ "$gitlab_debian_version" = "bullseye" ]
	then
		gitlab_source_sha256=$gitlab_arm64_bullseye_source_sha256
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
