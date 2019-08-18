gitlab_version="12.1.6"

gitlab_x86_64_source_sha256="af4251dd4d0c5ff42f69e6ac09d4767e8be41314b63993a5959790ac78657c91"

gitlab_arm_source_sha256="adfa0120282fcc84e9dca85196dcc28dc2763d072581857fc592ef35ab3821ab"

gitlab_filename="gitlab-ce-${gitlab_version}.deb"

# Action to do in case of failure of the package_check
package_check_action() {
	local sysctl_file="$final_path/embedded/cookbooks/package/resources/gitlab_sysctl.rb"
	if [ ! -f "$sysctl_file" ]; then
		sysctl_file="$final_path/embedded/cookbooks/package/resources/sysctl.rb"
	fi
	ynh_replace_string --match_string="command \"sysctl -e --system\"" --replace_string="command \"sysctl -e --system || true\"" --target_file=$sysctl_file
}
