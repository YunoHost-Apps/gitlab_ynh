gitlab_version="12.10.9"

# sha256sum found here: https://packages.gitlab.com/gitlab

gitlab_x86_64_debian_version="$(lsb_release -sc)"

if [ "$gitlab_x86_64_debian_version" = "buster" ]
then
	gitlab_x86_64_source_sha256="09b87fa74ee1c0c6fec6b01fea1dfe76f31be89bb3fc761c89552250b462cd49"
else
	gitlab_x86_64_source_sha256="c80a72d87cbc1c0f0acb919afa2930b1b1b016b1e0478d09e03bbedc12948960"
fi

gitlab_arm_source_sha256="c8632f81b94bec91caf8e912070d846a4f9e165f46d7a84ecae83a4ae12d5cda"

gitlab_filename="gitlab-ce-${gitlab_version}.deb"

# Action to do in case of failure of the package_check
package_check_action() {
	local sysctl_file="$final_path/embedded/cookbooks/package/resources/gitlab_sysctl.rb"
	ynh_replace_string --match_string="command \"sysctl -e \(.*\)\"" --replace_string="command \"sysctl -e \1 || true\"" --target_file=$sysctl_file
	
	sysctl_file="/opt/gitlab/embedded/cookbooks/package/recipes/sysctl.rb"
	ynh_replace_string --match_string="command \"sysctl -e \(.*\)\"" --replace_string="command \"sysctl -e \1 || true\"" --target_file=$sysctl_file
}
