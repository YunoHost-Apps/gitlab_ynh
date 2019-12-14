gitlab_version="12.5.4"

gitlab_x86_64_source_sha256="f4322459222f65558d345ff048028e91fb21b40fd318eb702737103aa2b09c18"

gitlab_arm_source_sha256="382890913a38f942f060c604248b3337e6c1da7ee59fb32737617963fb8ce5d4"

gitlab_filename="gitlab-ce-${gitlab_version}.deb"

# Action to do in case of failure of the package_check
package_check_action() {
	local sysctl_file="$final_path/embedded/cookbooks/package/resources/gitlab_sysctl.rb"
	if [ ! -f "$sysctl_file" ]; then
		sysctl_file="$final_path/embedded/cookbooks/package/resources/sysctl.rb"
	fi
	ynh_replace_string --match_string="command \"sysctl -e --system\"" --replace_string="command \"sysctl -e --system || true\"" --target_file=$sysctl_file
}
