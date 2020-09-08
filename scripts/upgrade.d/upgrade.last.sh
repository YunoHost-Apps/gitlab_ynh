#!/bin/bash

gitlab_version="13.3.4"

# sha256sum found here: https://packages.gitlab.com/gitlab

gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_buster_source_sha256="bf0d2924f10765d08724ea78d8f5ceff4dc4d25d14a5f282aa27d62640f21d23"

gitlab_arm_buster_source_sha256="ee9b8ac7816dbedf73e319fea4c14ac1c743f06bad4a2597e5753f81789337d1"

gitlab_x86_64_stretch_source_sha256="bc6800fdd5f91cb18c712ea15e93887141b81658566c780231aa63051cc9fcf0"

gitlab_arm_stretch_source_sha256="362ab23dfc97814027c428e23900337223d3ae4c1c9220ad35b7ffd341f666cc"

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
