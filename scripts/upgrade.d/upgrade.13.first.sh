#!/bin/bash

# It's required to upgrade to the latest 13.0.x version before to another 13.X verion.
gitlab_version="13.0.12"

# sha256sum found here: https://packages.gitlab.com/gitlab

gitlab_x86_64_buster_source_sha256="b568a8f45fdcb0c94e125fcc1e393e3f7364a4ab04d195bcf9b0797e71e0a8dd"

gitlab_x86_64_stretch_source_sha256="464b3d5923d945856fc851d0a01fc43fe223003a32a80bf90a84b599009fdce7"

gitlab_arm_stretch_source_sha256="39d7af79b80da73f26c8d2fa1ff95dfbca1573d36d6ee362e6f8fadceb17325e"

architecture=$(ynh_app_setting_get --app="$app" --key=architecture)

if [ "$architecture" = "x86-64" ]; then
	gitlab_debian_version="$(lsb_release -sc)"
	
	if [ "$gitlab_debian_version" = "bullseye" ]
	then
		gitlab_debian_version="buster"
	fi
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