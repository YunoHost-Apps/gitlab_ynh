#!/bin/bash

gitlab_version="13.6.3"

# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="buster"

gitlab_x86_64_buster_source_sha256="1a8092038da1541e8306d0d17e2d744cee8919908f41e37d80f48ad6273cde5c"

gitlab_arm_buster_source_sha256="3d18ce34311a8e19efbc8aec5bb9c58fa7c41558ad0b476685c18e828bf53d6c"

architecture=$(ynh_app_setting_get --app="$app" --key=architecture)

if [ "$architecture" = "x86-64" ]; then
	gitlab_source_sha256=$gitlab_x86_64_buster_source_sha256
elif [ "$architecture" = "arm" ]; then
	gitlab_source_sha256=$gitlab_arm_buster_source_sha256
fi

gitlab_filename="gitlab-ce-${gitlab_version}.deb"

# Action to do in case of failure of the package_check
package_check_action() {
	local sysctl_file="$final_path/embedded/cookbooks/package/resources/gitlab_sysctl.rb"
	ynh_replace_string --match_string="command \"sysctl -e \(.*\)\"" --replace_string="command \"sysctl -e \1 || true\"" --target_file=$sysctl_file
	
	sysctl_file="/opt/gitlab/embedded/cookbooks/package/recipes/sysctl.rb"
	ynh_replace_string --match_string="command \"sysctl -e \(.*\)\"" --replace_string="command \"sysctl -e \1 || true\"" --target_file=$sysctl_file
}
