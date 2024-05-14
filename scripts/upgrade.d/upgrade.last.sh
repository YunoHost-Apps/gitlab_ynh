#!/bin/bash

gitlab_version="16.11.2"

# Upgrade path: https://gitlab-com.gitlab.io/support/toolbox/upgrade-path/
# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_bookworm_source_sha256="339c827c08697817df5ed05387df9a58d2bf138181bb9c2b7b11a3803ab12e7c"
gitlab_x86_64_bullseye_source_sha256="6199c64689c31cf48225d064001f645540c139931699930fba4a9ad1e539c205"
gitlab_x86_64_buster_source_sha256="433bd5d6d2988b276d3767912e3035f3eb913d7e98a7ceb46e0325a4be0af0b4"

gitlab_arm64_bookworm_source_sha256="98e259ffe7c1466836b762c7b41e7d1203b31cc440129046ec1ca0072ae76df1"
gitlab_arm64_bullseye_source_sha256="9c53d88dff37bd64b1e5d9832edec5984a6420475d21dc32cb46281268eaafec"
gitlab_arm64_buster_source_sha256="951bb731adf2177b1fd74b0cc0f774cd7ee3b4ea951216cf1f245a78bcbc6159"

gitlab_arm_bookworm_source_sha256=""
gitlab_arm_bullseye_source_sha256="56180fb6c7565fbccff14d868ccb3412a89c11212726a91e576df8fce5d79288"
gitlab_arm_buster_source_sha256="b5e42c8f3c32683df957d1522c39af0165a33e27132a55fb18690db56f662ab8"

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
