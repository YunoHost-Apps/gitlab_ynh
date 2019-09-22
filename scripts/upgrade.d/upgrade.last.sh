gitlab_version="12.3.0"

gitlab_x86_64_source_sha256="57789874ddf80b1cfafe9bff7cc8dacb8af92852a48f9459d1b7b29dafae099a"

gitlab_arm_source_sha256="06ea031f23ba9375e014b142c53da12fa76587f3039c6c1a97952a9b1d271b85"

gitlab_filename="gitlab-ce-${gitlab_version}.deb"

# Action to do in case of failure of the package_check
package_check_action() {
	local sysctl_file="$final_path/embedded/cookbooks/package/resources/gitlab_sysctl.rb"
	if [ ! -f "$sysctl_file" ]; then
		sysctl_file="$final_path/embedded/cookbooks/package/resources/sysctl.rb"
	fi
	ynh_replace_string --match_string="command \"sysctl -e --system\"" --replace_string="command \"sysctl -e --system || true\"" --target_file=$sysctl_file
}
