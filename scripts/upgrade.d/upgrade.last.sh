gitlab_version="12.3.4"

gitlab_x86_64_source_sha256="6b913d17bca52e955429081e3331c3fc9003f4087c37b06019f124d41bce3c26"

gitlab_arm_source_sha256="c09fb0ba3ec71574d8fa0efc6b1c3afbc075cebfd8e5bd903a21be9b6e3e2a1b"

gitlab_filename="gitlab-ce-${gitlab_version}.deb"

# Action to do in case of failure of the package_check
package_check_action() {
	local sysctl_file="$final_path/embedded/cookbooks/package/resources/gitlab_sysctl.rb"
	if [ ! -f "$sysctl_file" ]; then
		sysctl_file="$final_path/embedded/cookbooks/package/resources/sysctl.rb"
	fi
	ynh_replace_string --match_string="command \"sysctl -e --system\"" --replace_string="command \"sysctl -e --system || true\"" --target_file=$sysctl_file
}
