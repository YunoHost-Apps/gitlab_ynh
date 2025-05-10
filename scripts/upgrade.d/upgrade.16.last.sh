#!/bin/bash

gitlab_version="16.11.10"

# Upgrade path: https://gitlab-com.gitlab.io/support/toolbox/upgrade-path/
# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_bookworm_source_sha256="4312fe0d2be18beaf3af927ed6e34cb5a4048275315c5415922adc600650c52f"
gitlab_x86_64_bullseye_source_sha256="f069370fd9d8a893a628a66a1ea4e4d857440ab0fea43d289d2177182b65e0da"
gitlab_x86_64_buster_source_sha256="4f7c9d78220678eb0f2e51e6160269d8f7dac8cc247e7f0f3fb808032ea2386e"

gitlab_arm64_bookworm_source_sha256="5bc3c67dad538665ba11269fc7d1eb21234171822381f11d0d17b242fe5c8067"
gitlab_arm64_bullseye_source_sha256="3da28c1d1d4f88e39bfc546a621aee984f5a90072f3dd8756587fa7b9c70aa40"
gitlab_arm64_buster_source_sha256="9d15d02897c3488e9121dd300a0df90ea0e10ee9e0d74d98ffd3dd79831c7f06"

gitlab_arm_bookworm_source_sha256=""
gitlab_arm_bullseye_source_sha256="0dc39bd5a290cace83c0291c8577dbfe049db992b114689bfd8bf94b135a57ec"
gitlab_arm_buster_source_sha256="951e00e6ab1a5889601e7a3732157f8b20f14cd74eb1eba26443c1785c07e1f7"

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
