#!/bin/bash

gitlab_version="13.1.0"

# sha256sum found here: https://packages.gitlab.com/gitlab

gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_buster_source_sha256="0ea54906b2f29f0bfcc9d4cad99ea399966055b1418633d0f62d46aea020877d"

gitlab_arm_buster_source_sha256="2f7b2cc169a6de6152abf927214ee47f26634a5fa24ee55535ba7bb5074fd2b5"

gitlab_x86_64_stretch_source_sha256="c16d69de22fa701dbb4755756544c839ae82a519ac3516901f644add89ff1767"

gitlab_arm_stretch_source_sha256="f24b6f085b1b1a426a277085b51f17d6821aaca8ff12dd888b4d294ecb9fef68"

architecture=$(ynh_app_setting_get --app="$app" --key=architecture)

if [ "$architecture" = "x86-64" ]; then
	if [ "$gitlab_debian_version" = "buster" ]
	then
		gitlab_source_sha256=$gitlab_x86_64_buster_source_sha256
	else
		gitlab_source_sha256=$gitlab_x86_64_stretch_source_sha256
	fi
elif [ "$architecture" = "arm" ]; then
	if [ "$gitlab_debian_version" = "buster" ]
	then
		gitlab_source_sha256=$gitlab_arm_buster_source_sha256
	else
		gitlab_source_sha256=$gitlab_arm_stretch_source_sha256
	fi
fi

gitlab_filename="gitlab-ce-${gitlab_version}.deb"

# Action to do in case of failure of the package_check
package_check_action() {
	local sysctl_file="$final_path/embedded/cookbooks/package/resources/gitlab_sysctl.rb"
	ynh_replace_string --match_string="command \"sysctl -e \(.*\)\"" --replace_string="command \"sysctl -e \1 || true\"" --target_file=$sysctl_file
	
	sysctl_file="/opt/gitlab/embedded/cookbooks/package/recipes/sysctl.rb"
	ynh_replace_string --match_string="command \"sysctl -e \(.*\)\"" --replace_string="command \"sysctl -e \1 || true\"" --target_file=$sysctl_file
}
