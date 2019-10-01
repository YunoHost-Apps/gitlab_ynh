gitlab_version="12.3.2"

gitlab_x86_64_source_sha256="4797306a282b46734533c53b7af79e0043b0a19e003e3461433c2a82ec34f0e3"

gitlab_arm_source_sha256="65a0ff5e681bb2078ea6dfe8032aad88317997a6058dc5243c17060839f82151"

gitlab_filename="gitlab-ce-${gitlab_version}.deb"

# Action to do in case of failure of the package_check
package_check_action() {
	local sysctl_file="$final_path/embedded/cookbooks/package/resources/gitlab_sysctl.rb"
	if [ ! -f "$sysctl_file" ]; then
		sysctl_file="$final_path/embedded/cookbooks/package/resources/sysctl.rb"
	fi
	ynh_replace_string --match_string="command \"sysctl -e --system\"" --replace_string="command \"sysctl -e --system || true\"" --target_file=$sysctl_file
}
