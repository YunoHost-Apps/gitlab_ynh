gitlab_version="12.2.5"

gitlab_x86_64_source_sha256="c583dc0ac520ecc5b190410379b935f9d2ae8c644a95f5a93e0423d16f0450f1"

gitlab_arm_source_sha256="b2b5522b331be7df7c061196065750317c4819313ce963a96e557a04fba6ccaf"

gitlab_filename="gitlab-ce-${gitlab_version}.deb"

# Action to do in case of failure of the package_check
package_check_action() {
	local sysctl_file="$final_path/embedded/cookbooks/package/resources/gitlab_sysctl.rb"
	if [ ! -f "$sysctl_file" ]; then
		sysctl_file="$final_path/embedded/cookbooks/package/resources/sysctl.rb"
	fi
	ynh_replace_string --match_string="command \"sysctl -e --system\"" --replace_string="command \"sysctl -e --system || true\"" --target_file=$sysctl_file
}
