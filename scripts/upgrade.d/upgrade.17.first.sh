#!/bin/bash

gitlab_version="17.0.8"

# Upgrade path: https://gitlab-com.gitlab.io/support/toolbox/upgrade-path/
# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_bookworm_source_sha256="ea2f87a9ea44f580ade6cd8f685860e215ef10852738e4dfba11b72a9f9d3200"
gitlab_x86_64_bullseye_source_sha256="5564089c7ea4c8979b77c6a517927d4c0988923af77b93fef03d4253d981fb3c"
gitlab_x86_64_buster_source_sha256="ece96030fcea855fda4eff23786acfbb95c0c257a1b6b03da6b0dee9b28cc252"

gitlab_arm64_bookworm_source_sha256="1665761badffcad7b74593c8069aeec2c27c5072ab8163df178519eb095f1349"
gitlab_arm64_bullseye_source_sha256="81879fd9db595e624f5c9663e22713d7a0ff113830459a389c222eaf85ca89a0"
gitlab_arm64_buster_source_sha256="9f086adba6cde33c934d42875f7034e6bc798ca3bf6ce6a0dc703c976b9386d7"

gitlab_arm_bookworm_source_sha256=""
gitlab_arm_bullseye_source_sha256="3ca9052b0d1d07fe29d1ae3c8a28028d8492e4beaf41a9fb766f1ecc631bd233"
gitlab_arm_buster_source_sha256="3153a7fc455935220fb9e16f145b5829e0abfcab81f9cac89dff6e033897a384"

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
