#!/bin/bash

# It's required to upgrade to the latest 12.0.x version before to another 12.X verion.
gitlab_version="12.0.12"

# There is no buster version for gitlab 12.0.X
gitlab_debian_version="stretch"

gitlab_x86_64_stretch_source_sha256="e80cda4c328c2627278a3d74dbdd53420e1fec9ecbeaeb5d4dcb4773726e5904"

gitlab_arm_stretch_source_sha256="a0862e3c31b61d9274a55b7307d15daa5258473ccb97b8ae0d807f7474c971df"

architecture=$(ynh_app_setting_get --app="$app" --key=architecture)

if [ "$architecture" = "x86-64" ]; then
	gitlab_source_sha256=$gitlab_x86_64_stretch_source_sha256
elif [ "$architecture" = "arm" ]; then
	gitlab_source_sha256=$gitlab_arm_stretch_source_sha256
fi

gitlab_filename="gitlab-ce-${gitlab_version}.deb"

# Action to do in case of failure of the package_check
package_check_action() {
	local sysctl_file="$final_path/embedded/cookbooks/package/resources/sysctl.rb"
	ynh_replace_string --match_string="command \"sysctl -e \(.*\)\"" --replace_string="command \"sysctl -e \1 || true\"" --target_file=$sysctl_file
}

