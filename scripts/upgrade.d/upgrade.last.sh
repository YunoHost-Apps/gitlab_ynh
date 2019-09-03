gitlab_version="12.2.3"

gitlab_x86_64_source_sha256="c7cb22bf7aee5bba4b9ebc2f04add53b68092bca18130a2ab3697a8583687770"

gitlab_arm_source_sha256="2be45cc1bb8a9f785c1ce8469bc11996be323c474b1d0d812b37e75a44bdd4dd"

gitlab_filename="gitlab-ce-${gitlab_version}.deb"

# Action to do in case of failure of the package_check
package_check_action() {
	local sysctl_file="$final_path/embedded/cookbooks/package/resources/gitlab_sysctl.rb"
	if [ ! -f "$sysctl_file" ]; then
		sysctl_file="$final_path/embedded/cookbooks/package/resources/sysctl.rb"
	fi
	ynh_replace_string --match_string="command \"sysctl -e --system\"" --replace_string="command \"sysctl -e --system || true\"" --target_file=$sysctl_file
}
