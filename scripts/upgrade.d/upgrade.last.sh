gitlab_version="12.8.6"

gitlab_x86_64_source_sha256="38ad319f529d6fd7166a421077ee0d5e42f299443fe81a071523ed5da0213b13"

gitlab_arm_source_sha256="8b9e1f55d13113006071d7da074e5b934258c6a8618c59a98a37d11e298a55e7"

gitlab_filename="gitlab-ce-${gitlab_version}.deb"

# Action to do in case of failure of the package_check
package_check_action() {
	local sysctl_file="$final_path/embedded/cookbooks/package/resources/gitlab_sysctl.rb"
	if [ ! -f "$sysctl_file" ]; then
		sysctl_file="$final_path/embedded/cookbooks/package/resources/sysctl.rb"
	fi
	ynh_replace_string --match_string="command \"sysctl -e --system\"" --replace_string="command \"sysctl -e --system || true\"" --target_file=$sysctl_file
}
