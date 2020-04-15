gitlab_version="12.9.2"

gitlab_x86_64_source_sha256="781d21de10c4b88582d25af19cd3d85d9618a995f930d1954ea9dc0fa76d7ea9"

gitlab_arm_source_sha256="09eb415d2e55af64294606e25cfebd508c8cc59218475ed26e99f6baccfe1218"

gitlab_filename="gitlab-ce-${gitlab_version}.deb"

# Action to do in case of failure of the package_check
package_check_action() {
	local sysctl_file="$final_path/embedded/cookbooks/package/resources/gitlab_sysctl.rb"
	if [ ! -f "$sysctl_file" ]; then
		sysctl_file="$final_path/embedded/cookbooks/package/resources/sysctl.rb"
	fi
	ynh_replace_string --match_string="command \"sysctl -e --system\"" --replace_string="command \"sysctl -e --system || true\"" --target_file=$sysctl_file
}
