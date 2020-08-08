#!/bin/bash

gitlab_version="13.2.3"

# sha256sum found here: https://packages.gitlab.com/gitlab

gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_buster_source_sha256="0ecce1957260de9cca3325fc0772a5976d604f3d2d5a81e10cfda7aba4dd9f7b"

gitlab_arm_buster_source_sha256="0f5e1579ced77650950a062dd89dfb0c6c9a117c94c2204c9a10d6f37f0fe4d9"

gitlab_x86_64_stretch_source_sha256="d4437de930401e5417d5afb093a3d307e3bccb1bf71cde2fd7c79f98577604e4"

gitlab_arm_stretch_source_sha256="5dff5d413392c2ab1fd549e938e7cc17c39b82ced92a2efcd322e5e7193ce259"

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
