#!/bin/bash

gitlab_version="15.5.1"

# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_bullseye_source_sha256="cd5cb968d9b8b54ca2227615200d2d7a481e72765a9a0ad134ffb2391219d061"
gitlab_x86_64_buster_source_sha256="00a6feca1affc84a31f2e49e2dd60637647f84dfcedac7f4e8775d5f1c023c66"

gitlab_arm64_bullseye_source_sha256="5454a26df52f7a85181b89a5a453a1699677f8307963236924f19119cd200ac0"
gitlab_arm64_buster_source_sha256="0697886fa8bebe60858f189d5eca22d89e33f6446b28f30f3d87ca4aef862c0e"

gitlab_arm_buster_source_sha256="c9ead418ba693c69345b615f4c1e98c8af3f8bffb30cbd5d807a531e235b9f7f"
gitlab_arm_bullseye_source_sha256="177c93e309e362018ce4a4ff572107dc86e916932c5ab2ff5f2271eb8aaf2995"

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
		# If the version for arm doesn't exist, then use an older one
		if [ -z "$gitlab_arm_buster_source_sha256" ]; then
			gitlab_version="15.5.1"
			gitlab_arm_buster_source_sha256="c9ead418ba693c69345b615f4c1e98c8af3f8bffb30cbd5d807a531e235b9f7f"
		fi
		gitlab_source_sha256=$gitlab_arm_buster_source_sha256
	elif [ "$gitlab_debian_version" = "buster" ]
	then
		# If the version for arm doesn't exist, then use an older one
		if [ -z "$gitlab_arm_bullseye_source_sha256" ]; then
			gitlab_version="15.5.1"
			gitlab_arm_bullseye_source_sha256="177c93e309e362018ce4a4ff572107dc86e916932c5ab2ff5f2271eb8aaf2995"
		fi
		gitlab_source_sha256=$gitlab_arm_bullseye_source_sha256
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
