#!/bin/bash

gitlab_version="16.10.3"

# Upgrade path: https://gitlab-com.gitlab.io/support/toolbox/upgrade-path/
# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_bookworm_source_sha256="4e90c49dfbf9dab75d6fdc57b03dbf5f72d1329f7993e153118eeb1d1b301a22"
gitlab_x86_64_bullseye_source_sha256="22996c02e54001b760125ad36198af2417ac93b0ada1241833e611054c29587f"
gitlab_x86_64_buster_source_sha256="21399c2d68090b4ec221b9dae0cf222a211ed57bd0c8085e59c203aa38ac6361"

gitlab_arm64_bookworm_source_sha256="4517e3ceb31f12740f9e2408603f0a954dda8a5633c198a59ebe2007512f804b"
gitlab_arm64_bullseye_source_sha256="20f7ae8a092a7c2713a67da7cc63de8bc6913a0f8aaea80e81a81ac0c9141f8c"
gitlab_arm64_buster_source_sha256="858f7bd4eb73a5535b0fe3d3fc1da3d3b7dede24afe79c1dd0b2eddaf731959a"

gitlab_arm_bookworm_source_sha256=""
gitlab_arm_bullseye_source_sha256="c2c769ec009e587a690329a7550a1f980847c20e65469e091296230ee61d12d6"
gitlab_arm_buster_source_sha256="150f799085d43eb21437591e424e96faec99110eb459b29a3c6d46182385683d"

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
