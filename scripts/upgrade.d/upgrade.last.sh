gitlab_version="12.2.4"

gitlab_x86_64_source_sha256="1b0f1c3629d31e5ff2d2b096428d5ded46d91f9708d66d9e99c785d15bf07095"

gitlab_arm_source_sha256="8090b16c59ccc7762b1c9737b58667fc3625a223dcd6b5c5855ae88291aa7601"

gitlab_filename="gitlab-ce-${gitlab_version}.deb"

# Action to do in case of failure of the package_check
package_check_action() {
	local sysctl_file="$final_path/embedded/cookbooks/package/resources/gitlab_sysctl.rb"
	if [ ! -f "$sysctl_file" ]; then
		sysctl_file="$final_path/embedded/cookbooks/package/resources/sysctl.rb"
	fi
	ynh_replace_string --match_string="command \"sysctl -e --system\"" --replace_string="command \"sysctl -e --system || true\"" --target_file=$sysctl_file
}
