#!/bin/bash

gitlab_version="16.3.0"

# Upgrade path: https://gitlab-com.gitlab.io/support/toolbox/upgrade-path/
# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_bookworm_source_sha256="a8ad48f975a51edd47156a097554ad145cb6ca7458e7e2625a395db10c3a2e67"
gitlab_x86_64_bullseye_source_sha256="c768c9f82ffc5a9a11074970627c5f832eb416e5290ba878c7a4989900f1702a"
gitlab_x86_64_buster_source_sha256="89a5fb54f1e4ea27541e86e629916b5223db43c3582a52201d70f26fad649b52"

gitlab_arm64_bookworm_source_sha256="04a1b984b1b29ffe4ce1cbc7b4bb7b206de70552f4322d3bc9a2013ae2c641ec"
gitlab_arm64_bullseye_source_sha256="05d418d7d736af480dea73955175bf1e2becdfdb1a7467e4e3ffa86b55b29f31"
gitlab_arm64_buster_source_sha256="96d0aebf79d0f8efd630ef4a05d9e48f7a4436e600fd24ad312da8d8527f285b"

gitlab_arm_bookworm_source_sha256=""
gitlab_arm_bullseye_source_sha256="50ca0bdc687bfab76cd117dcc9dffa6ce6496c00e962c4e8f21354f74ed952f3"
gitlab_arm_buster_source_sha256="2a4e6e6708e0310251e3af71d670861ab8b787a12c7916b25c79b54b373b4f87"

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
