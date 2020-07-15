#!/bin/bash

gitlab_version="13.1.4"

# sha256sum found here: https://packages.gitlab.com/gitlab

gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_buster_source_sha256="b39df97b871b2def2287ddf3995fc44f9afa1ad68982a0beecfc2740761b769a"

gitlab_arm_buster_source_sha256="092b17f00cc36ccf08076c5194f8418e52c34a9f07aa6529d01ef0784c5bae88"

gitlab_x86_64_stretch_source_sha256="733ad6468e5ecd571a6233c88d1512c092591ada3f8bc24dcaa7f68f61d52d69"

gitlab_arm_stretch_source_sha256="26266529281d9c0b6c6f7b1d29b97de2f9c08a2ffb86ada18f09f29cc0fd0fef"

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
