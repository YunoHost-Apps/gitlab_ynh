gitlab_version="12.10.0"

gitlab_x86_64_source_sha256="ed24c9bd072b6f15f7c73367df04acba3e64ee53bb3562f25e768a2dda533ca2"

gitlab_arm_source_sha256="5d4b1d76997de08e9707e5cb17445a38ed832bd9995f31a5af0b87134b7f0834"

gitlab_filename="gitlab-ce-${gitlab_version}.deb"

# Action to do in case of failure of the package_check
package_check_action() {
	local sysctl_file="$final_path/embedded/cookbooks/package/resources/gitlab_sysctl.rb"
	if [ ! -f "$sysctl_file" ]; then
		sysctl_file="$final_path/embedded/cookbooks/package/resources/sysctl.rb"
	fi
	ynh_replace_string --match_string="command \"sysctl -e --system\"" --replace_string="command \"sysctl -e --system || true\"" --target_file=$sysctl_file
}
