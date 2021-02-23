#!/bin/bash

gitlab_version="13.9.0"

# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="buster"

gitlab_x86_64_buster_source_sha256="5642866110f64ce3a424d312b0779e249595acbcfcb1edff81e6d6c0345db3ce"

gitlab_arm_buster_source_sha256="4bb579c84a854c0759d2b67f123d1a0ffb96743edf8fce6cbbef5d40147bbde4"

architecture=$(ynh_app_setting_get --app="$app" --key=architecture)

if [ "$architecture" = "x86-64" ]; then
	gitlab_source_sha256=$gitlab_x86_64_buster_source_sha256
elif [ "$architecture" = "arm" ]; then
	gitlab_source_sha256=$gitlab_arm_buster_source_sha256
fi

gitlab_filename="gitlab-ce-${gitlab_version}.deb"

# Action to do in case of failure of the package_check
package_check_action() {
	ynh_replace_string --match_string="# package\['modify_kernel_parameters'\] = true" --replace_string="package['modify_kernel_parameters'] = false" --target_file="$config_path/gitlab.rb"
}
