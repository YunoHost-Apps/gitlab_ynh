#!/bin/bash

# It's required to upgrade to the latest 13.0.x version before to another 13.X verion.
gitlab_version="13.0.6"

# sha256sum found here: https://packages.gitlab.com/gitlab

gitlab_x86_64_buster_source_sha256="91a3486de88d1f0ce108d0f0c9adafc83e24c678e5ce2750ec8d52d75e467c1d"

gitlab_x86_64_stretch_source_sha256="175df478d80d15cbc19b69dee0c312058ba0530bed34f13050a25bb5b280315c"

gitlab_arm_stretch_source_sha256="cfd4f0f72ec2068d1566dd8699adedef210ada30644885e0d74beded3dd1b2b3"

architecture=$(ynh_app_setting_get --app="$app" --key=architecture)

if [ "$architecture" = "x86-64" ]; then
	gitlab_debian_version="$(lsb_release -sc)"

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