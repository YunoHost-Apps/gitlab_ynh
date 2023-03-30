#!/bin/bash

gitlab_version="15.10.0"

# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_bullseye_source_sha256="c8f5aca04549d3f9ba636ca67e76e9bf2b5a6a249a4a16d79365d17856a53d4d"
gitlab_x86_64_buster_source_sha256="223b4c3eafd3edf44d9b8153f834c24aface03ea7585db4ccb0292e582fd6345"

gitlab_arm64_bullseye_source_sha256="63d29c92eb956631a478735a6c692bbb315c898b2041b2f545c12302b230c97f"
gitlab_arm64_buster_source_sha256="8a29a50bab93d7bbd2bfcfbd968c051739a20d2750c3cee0da2d676738928a77"

gitlab_arm_bullseye_source_sha256="a7a195bf8a74e6ca688de2debe23c0cd5482d989377dcaf7042df484731e10cc"
gitlab_arm_buster_source_sha256="60f4c441e8f6f25934d6be3bcb9a8fe058b05b7076e7087a18ff747f9afa4b3a"

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
