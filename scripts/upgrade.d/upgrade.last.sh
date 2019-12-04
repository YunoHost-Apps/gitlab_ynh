gitlab_version="12.5.2"

gitlab_x86_64_source_sha256="fdf50eb4d2645ff00a8062d5af113bc778e32d9c8a6f1c442a9e52cd68d4a577"

gitlab_arm_source_sha256="7c9262ae07bf2539ea128253545220cd3b41b34a508a88eb731457d2a4f454f0"

gitlab_filename="gitlab-ce-${gitlab_version}.deb"

# Action to do in case of failure of the package_check
package_check_action() {
	local sysctl_file="$final_path/embedded/cookbooks/package/resources/gitlab_sysctl.rb"
	if [ ! -f "$sysctl_file" ]; then
		sysctl_file="$final_path/embedded/cookbooks/package/resources/sysctl.rb"
	fi
	ynh_replace_string --match_string="command \"sysctl -e --system\"" --replace_string="command \"sysctl -e --system || true\"" --target_file=$sysctl_file
}
