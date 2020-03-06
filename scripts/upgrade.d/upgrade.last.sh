gitlab_version="12.8.2"

gitlab_x86_64_source_sha256="6c45ab23f3b7abc927ac15035ace7bdf1692c65b5bb657686b8cc23f7fdcd6d7"

gitlab_arm_source_sha256="1476be7c19f85d90c6abf1254ba1f2d4380833934e2471f788d5179099eb1122"

gitlab_filename="gitlab-ce-${gitlab_version}.deb"

# Action to do in case of failure of the package_check
package_check_action() {
	local sysctl_file="$final_path/embedded/cookbooks/package/resources/gitlab_sysctl.rb"
	if [ ! -f "$sysctl_file" ]; then
		sysctl_file="$final_path/embedded/cookbooks/package/resources/sysctl.rb"
	fi
	ynh_replace_string --match_string="command \"sysctl -e --system\"" --replace_string="command \"sysctl -e --system || true\"" --target_file=$sysctl_file
}
