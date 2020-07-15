#!/bin/bash

gitlab_version="12.10.11"

# sha256sum found here: https://packages.gitlab.com/gitlab

gitlab_x86_64_buster_source_sha256="1e5564604ddeb6bd8b152856e81a01230b5c66e41e1c07ac9f9f7c4593245b3c"

gitlab_x86_64_stretch_source_sha256="75bff35148b64cf08cd428103c5fc90b597b5f20b4feede38019bdcaa33a3fda"

gitlab_arm_stretch_source_sha256="07581f11cf2c76fe00afb7577df14fec86af1aa9c5ea6b3aea4997397e5915c6"

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
