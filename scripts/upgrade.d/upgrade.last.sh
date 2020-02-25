gitlab_version="12.8.1"

gitlab_x86_64_source_sha256="46ce55698d75c29e1a8558f757f56361c738420a878e30f2854731761378e746"

gitlab_arm_source_sha256="ce3ff5209a56f0d50555dbd9f82f26c30e8b04a0f19b3d829e545c14a07c4813"

gitlab_filename="gitlab-ce-${gitlab_version}.deb"

# Action to do in case of failure of the package_check
package_check_action() {
	local sysctl_file="$final_path/embedded/cookbooks/package/resources/gitlab_sysctl.rb"
	if [ ! -f "$sysctl_file" ]; then
		sysctl_file="$final_path/embedded/cookbooks/package/resources/sysctl.rb"
	fi
	ynh_replace_string --match_string="command \"sysctl -e --system\"" --replace_string="command \"sysctl -e --system || true\"" --target_file=$sysctl_file
}
