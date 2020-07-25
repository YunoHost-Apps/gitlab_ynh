#!/bin/bash

# It's required to upgrade to the latest 13.0.x version before to another 13.X verion.
gitlab_version="13.0.10"

# sha256sum found here: https://packages.gitlab.com/gitlab

gitlab_x86_64_buster_source_sha256="d2b964e313983e03c8920327972ccd500800745b37db95227977765ec1ae7f0d"

gitlab_x86_64_stretch_source_sha256="1d378f5488aeaafa08ffd05e316e384210ed53e572282d2a7270de6605d45b64"

gitlab_arm_stretch_source_sha256="cd5987686dcfa36acfd8ec37c9ac53a27c0f472948c9418745f0760b6e861ce3"

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