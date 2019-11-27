gitlab_version="12.5.0"

gitlab_x86_64_source_sha256="b986d2214b11f6775b16360f6473ae06ad589ef4f7e1769a3f401032369db8b8"

gitlab_arm_source_sha256="e38bd488ee7ea2e9eebd5e7f6d2b804d7a5f1f4390c772afda585d015273e422"

gitlab_filename="gitlab-ce-${gitlab_version}.deb"

# Action to do in case of failure of the package_check
package_check_action() {
	local sysctl_file="$final_path/embedded/cookbooks/package/resources/gitlab_sysctl.rb"
	if [ ! -f "$sysctl_file" ]; then
		sysctl_file="$final_path/embedded/cookbooks/package/resources/sysctl.rb"
	fi
	ynh_replace_string --match_string="command \"sysctl -e --system\"" --replace_string="command \"sysctl -e --system || true\"" --target_file=$sysctl_file
}
