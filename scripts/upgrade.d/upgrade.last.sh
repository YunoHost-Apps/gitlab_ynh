#!/bin/bash

gitlab_version="16.0.1"

# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_bullseye_source_sha256="80c07ddf3d1df889a039b0aeb098bd34b836819016a0d33368e7838bb9d95070"
gitlab_x86_64_buster_source_sha256="03d6417811d81fadda4526a7c8d82529c25c6cb60ee9d4e1e6e82fb2d447e1b0"

gitlab_arm64_bullseye_source_sha256="6649ef36a3d3e970ae2eb0b4c70ca8edb6c22c8daa9d955af2b9651a8634f06f"
gitlab_arm64_buster_source_sha256="20524140314569f13a0ed1bbfb03e1338976762b20296848b63c7811e2f01e3c"

gitlab_arm_buster_source_sha256="c5a5ffa84706e9cc136ff2daded867acf2308c06a4145ae4632a672b0187268b"
gitlab_arm_bullseye_source_sha256="5ae1219572c78778cc061ed5e13e03ecf3901c317bd218d4a454322bf886f45e"

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
