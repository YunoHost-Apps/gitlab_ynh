#!/bin/bash

gitlab_version="17.1.1"

# Upgrade path: https://gitlab-com.gitlab.io/support/toolbox/upgrade-path/
# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_bookworm_source_sha256="a850a4fc326ceabd2da3c687ef076bdfb86a212134ed41d9f87a87406a1bd0cf"
gitlab_x86_64_bullseye_source_sha256="652eaaf440b9729cc8a09da1982a1fac177ab425ed94ca6f78944f5bd42eaf9f"
gitlab_x86_64_buster_source_sha256="f50136bdd32781a89238adbc6456b43c72f74235bb3e21c4c5005549f5f54508"

gitlab_arm64_bookworm_source_sha256="dd893cd820902c3b82abb1feace7dc68824cfadbd2175c0ef0a0f1ec12dca5da"
gitlab_arm64_bullseye_source_sha256="a4f317b6750708dd9be0ee3cee0109bc44fb003df48e02a066af7b7433ff6053"
gitlab_arm64_buster_source_sha256="e3dfef1873d6a6caf802ea9c6d662b95c4f71c7cd1dce11b5b6e7c64c32109c5"

gitlab_arm_bookworm_source_sha256=""
gitlab_arm_bullseye_source_sha256="ac1fd6d947f88208fe8b0439c4574d117a9ad4fdfd18d5f934d981672c15465e"
gitlab_arm_buster_source_sha256="1f2f8d497a29fd0552188920616cf60896157fca99d08af6e365c99d3cd1953d"

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
