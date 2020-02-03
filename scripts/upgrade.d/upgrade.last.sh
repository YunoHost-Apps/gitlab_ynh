gitlab_version="12.7.4"

gitlab_x86_64_source_sha256="d6e425ffd161f763a442ed8e039d3fa6d1fb051d5bc7a36aae765c265d39b0c1"

gitlab_arm_source_sha256="2605a2253a80e5bf13aa675bee991ffc1f6a4b14adb977af80e8a5edfdc5cdd6"

gitlab_filename="gitlab-ce-${gitlab_version}.deb"

# Action to do in case of failure of the package_check
package_check_action() {
	local sysctl_file="$final_path/embedded/cookbooks/package/resources/gitlab_sysctl.rb"
	if [ ! -f "$sysctl_file" ]; then
		sysctl_file="$final_path/embedded/cookbooks/package/resources/sysctl.rb"
	fi
	ynh_replace_string --match_string="command \"sysctl -e --system\"" --replace_string="command \"sysctl -e --system || true\"" --target_file=$sysctl_file
}
