gitlab_version="12.9.3"

gitlab_x86_64_source_sha256="8260f00f7fcda9118155244415fd865fa53e41bb29047421d06f04a2b249e6f9"

gitlab_arm_source_sha256="1f99fd0d5d11a3a41cd1e3c018bdf2566a0085999111076c43fca31ff4d1cac1"

gitlab_filename="gitlab-ce-${gitlab_version}.deb"

# Action to do in case of failure of the package_check
package_check_action() {
	local sysctl_file="$final_path/embedded/cookbooks/package/resources/gitlab_sysctl.rb"
	if [ ! -f "$sysctl_file" ]; then
		sysctl_file="$final_path/embedded/cookbooks/package/resources/sysctl.rb"
	fi
	ynh_replace_string --match_string="command \"sysctl -e --system\"" --replace_string="command \"sysctl -e --system || true\"" --target_file=$sysctl_file
}
