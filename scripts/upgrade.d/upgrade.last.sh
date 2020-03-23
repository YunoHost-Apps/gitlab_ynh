gitlab_version="12.9.0"

gitlab_x86_64_source_sha256="fe547cd70cbc8cb89314e4ee69c96100cc34d9df476ba021ce5c036bb28bf501"

gitlab_arm_source_sha256="5865793add5e88c30d517234bd25795a489fa82f560406fbf715e460611e8a0f"

gitlab_filename="gitlab-ce-${gitlab_version}.deb"

# Action to do in case of failure of the package_check
package_check_action() {
	local sysctl_file="$final_path/embedded/cookbooks/package/resources/gitlab_sysctl.rb"
	if [ ! -f "$sysctl_file" ]; then
		sysctl_file="$final_path/embedded/cookbooks/package/resources/sysctl.rb"
	fi
	ynh_replace_string --match_string="command \"sysctl -e --system\"" --replace_string="command \"sysctl -e --system || true\"" --target_file=$sysctl_file
}
