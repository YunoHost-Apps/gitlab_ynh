#!/bin/bash

gitlab_version="15.6.0"

# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_bullseye_source_sha256="432d197845a62d8997c582e1f4364ee5b11c60e2cf446533195737b095bcadc5"
gitlab_x86_64_buster_source_sha256="d5367b484aa427f1c3c5a5fe6b73be3c1f9784231d039fd273d506fcbe3bc943"

gitlab_arm64_bullseye_source_sha256="d4cceddf769b8a7ac075276cf13262bf475e90c43d518d48134a4872e5727195"
gitlab_arm64_buster_source_sha256="93eaa468047f5d53903a7de3fabc999a730914b8ce420cef5608736ca98acf7f"

gitlab_arm_buster_source_sha256="762dd3669e4220494f654c57b984796c90b1b99c3f5f3c14e7bbbb2d429db461"
gitlab_arm_bullseye_source_sha256="184539ee24a1cb7f5c4e2f1ba3143e811473d1f2d2ed7501dedf23dc5d5029f7"

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
			gitlab_version="15.6.0"
			gitlab_arm_buster_source_sha256="762dd3669e4220494f654c57b984796c90b1b99c3f5f3c14e7bbbb2d429db461"
		fi
		gitlab_source_sha256=$gitlab_arm_buster_source_sha256
	elif [ "$gitlab_debian_version" = "buster" ]
	then
		# If the version for arm doesn't exist, then use an older one
		if [ -z "$gitlab_arm_bullseye_source_sha256" ]; then
			gitlab_version="15.6.0"
			gitlab_arm_bullseye_source_sha256="184539ee24a1cb7f5c4e2f1ba3143e811473d1f2d2ed7501dedf23dc5d5029f7"
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
