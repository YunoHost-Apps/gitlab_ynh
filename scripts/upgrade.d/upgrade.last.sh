gitlab_version="12.3.1"

gitlab_x86_64_source_sha256="e00c66eda3f9f0a6580c29c1b1d0825472a1f8240335d664337dde13ac6f479d"

gitlab_arm_source_sha256="c26cf58ae0ec97f55f471c3ebaad9a194b906fa8abae8dfca13df1bb103c5328"

gitlab_filename="gitlab-ce-${gitlab_version}.deb"

# Action to do in case of failure of the package_check
package_check_action() {
	local sysctl_file="$final_path/embedded/cookbooks/package/resources/gitlab_sysctl.rb"
	if [ ! -f "$sysctl_file" ]; then
		sysctl_file="$final_path/embedded/cookbooks/package/resources/sysctl.rb"
	fi
	ynh_replace_string --match_string="command \"sysctl -e --system\"" --replace_string="command \"sysctl -e --system || true\"" --target_file=$sysctl_file
}
