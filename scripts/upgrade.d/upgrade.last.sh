gitlab_version="12.6.2"

gitlab_x86_64_source_sha256="8550fc9fed49cb1f8e6f1e4d232752812bf530e53de23495e5710808f4b2fb61"

gitlab_arm_source_sha256="28df8fd5f5a1ba77a2214ff4bf3f32872d161ede8718eae1753bc90a23ef1b35"

gitlab_filename="gitlab-ce-${gitlab_version}.deb"

# Action to do in case of failure of the package_check
package_check_action() {
	local sysctl_file="$final_path/embedded/cookbooks/package/resources/gitlab_sysctl.rb"
	if [ ! -f "$sysctl_file" ]; then
		sysctl_file="$final_path/embedded/cookbooks/package/resources/sysctl.rb"
	fi
	ynh_replace_string --match_string="command \"sysctl -e --system\"" --replace_string="command \"sysctl -e --system || true\"" --target_file=$sysctl_file
}
