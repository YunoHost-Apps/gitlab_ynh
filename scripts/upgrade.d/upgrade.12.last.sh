#!/bin/bash

gitlab_version="12.10.12"

# sha256sum found here: https://packages.gitlab.com/gitlab

gitlab_x86_64_buster_source_sha256="17df2dfa71678109f7f1031b43d7c4e30ae34749258b9f48dd49380dd9cc3488"

gitlab_x86_64_stretch_source_sha256="fbe744d04544465f6c97fd6fbc0dc11fb36ce2a75c4e943d911027b189634bee"

gitlab_arm_stretch_source_sha256="43fc988516251295653d660b927a311593c22df31b58e5d3d91f40c8164a08ee"

architecture=$(ynh_app_setting_get --app="$app" --key=architecture)

if [ "$architecture" = "x86-64" ]; then
	gitlab_debian_version="$(lsb_release -sc)"

	if [ "$gitlab_debian_version" = "bullseye" ]
	then
		gitlab_debian_version="buster"
	fi
	if [ "$gitlab_debian_version" = "buster" ]
	then
		gitlab_source_sha256=$gitlab_x86_64_buster_source_sha256
	else
		gitlab_source_sha256=$gitlab_x86_64_stretch_source_sha256
	fi
elif [ "$architecture" = "arm" ]; then
	gitlab_debian_version="stretch"

	gitlab_source_sha256=$gitlab_arm_stretch_source_sha256
fi

gitlab_filename="gitlab-ce-${gitlab_version}.deb"

# Action to do in case of failure of the package_check
package_check_action() {
	local sysctl_file="$final_path/embedded/cookbooks/package/resources/gitlab_sysctl.rb"
	ynh_replace_string --match_string="command \"sysctl -e \(.*\)\"" --replace_string="command \"sysctl -e \1 || true\"" --target_file=$sysctl_file
	
	sysctl_file="/opt/gitlab/embedded/cookbooks/package/recipes/sysctl.rb"
	ynh_replace_string --match_string="command \"sysctl -e \(.*\)\"" --replace_string="command \"sysctl -e \1 || true\"" --target_file=$sysctl_file
}
