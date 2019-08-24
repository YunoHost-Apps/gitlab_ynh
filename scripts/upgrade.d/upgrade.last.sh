gitlab_version="12.2.1"

gitlab_x86_64_source_sha256="102040c54d112738cddadff9f661f0e010e2bf5172c6f6d8f635ed2f8b9de6f7"

gitlab_arm_source_sha256="8418907a9a2a67b703c334d8d83e941c296f68d79e358b49107d52e92909f3df"

gitlab_filename="gitlab-ce-${gitlab_version}.deb"

# Action to do in case of failure of the package_check
package_check_action() {
	local sysctl_file="$final_path/embedded/cookbooks/package/resources/gitlab_sysctl.rb"
	if [ ! -f "$sysctl_file" ]; then
		sysctl_file="$final_path/embedded/cookbooks/package/resources/sysctl.rb"
	fi
	ynh_replace_string --match_string="command \"sysctl -e --system\"" --replace_string="command \"sysctl -e --system || true\"" --target_file=$sysctl_file
}
