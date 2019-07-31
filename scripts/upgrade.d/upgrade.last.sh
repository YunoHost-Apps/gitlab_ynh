gitlab_version="12.1.3"

gitlab_x86_64_source_sha256="27f49d2249ce8af1750b4eb1133e5b9a9f9ccd4b38004a3b483e3f538ac13167"

gitlab_arm_source_sha256="4ca3f23d7e6d0f2e3dd288e811920bb85b44191f1da7befbd9606badb2a836dc"

gitlab_filename="gitlab-ce-${gitlab_version}.deb"

# Action to do in case of failure of the package_check
package_check_action() {
	local sysctl_file="$final_path/embedded/cookbooks/package/resources/gitlab_sysctl.rb"
	if [ ! -f "$sysctl_file" ]; then
		sysctl_file="$final_path/embedded/cookbooks/package/resources/sysctl.rb"
	fi
	ynh_replace_string --match_string="command \"sysctl -e --system\"" --replace_string="command \"sysctl -e --system || true\"" --target_file=$sysctl_file
}
