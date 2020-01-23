gitlab_version="12.7.0"

gitlab_x86_64_source_sha256="ff5c4f53f70f3db5499a6544e9ffc0998761b4f85d1544988f84e965058ea22b"

gitlab_arm_source_sha256="3518735ce086ecedb2fe2841ea717b0325bb99418a7d32e1cc87ce169815624e"

gitlab_filename="gitlab-ce-${gitlab_version}.deb"

# Action to do in case of failure of the package_check
package_check_action() {
	local sysctl_file="$final_path/embedded/cookbooks/package/resources/gitlab_sysctl.rb"
	if [ ! -f "$sysctl_file" ]; then
		sysctl_file="$final_path/embedded/cookbooks/package/resources/sysctl.rb"
	fi
	ynh_replace_string --match_string="command \"sysctl -e --system\"" --replace_string="command \"sysctl -e --system || true\"" --target_file=$sysctl_file
}
