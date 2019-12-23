gitlab_version="12.6.0"

gitlab_x86_64_source_sha256="bedb43836d6f901ae72afec8aa0e94ac4ea99a70f9e652002eaf2f6289682dd3"

gitlab_arm_source_sha256="2a2f4725a6231f416d7a804897ee96ecdcbce621e51e6092e8d95afcf58958b1"

gitlab_filename="gitlab-ce-${gitlab_version}.deb"

# Action to do in case of failure of the package_check
package_check_action() {
	local sysctl_file="$final_path/embedded/cookbooks/package/resources/gitlab_sysctl.rb"
	if [ ! -f "$sysctl_file" ]; then
		sysctl_file="$final_path/embedded/cookbooks/package/resources/sysctl.rb"
	fi
	ynh_replace_string --match_string="command \"sysctl -e --system\"" --replace_string="command \"sysctl -e --system || true\"" --target_file=$sysctl_file
}
