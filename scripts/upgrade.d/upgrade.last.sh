#!/bin/bash

gitlab_version="13.3.1"

# sha256sum found here: https://packages.gitlab.com/gitlab

gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_buster_source_sha256="20e4fcb15ac8fa8d94105230d6c895a4e4407ef11af81d67df08688bf68f9c41"

gitlab_arm_buster_source_sha256="9451b77c17d543b8dc813354e8bbb6e110856978fac9152e72a185308c1e8b9e"

gitlab_x86_64_stretch_source_sha256="41db62c708dd905198a05aeb63041f5103e639266914ecb1bb850bce9bdb12ca"

gitlab_arm_stretch_source_sha256="b7228cffe3124d765a78e06665e4a2f6fdec926fc8b2b67be4605461e96de3d7"

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
