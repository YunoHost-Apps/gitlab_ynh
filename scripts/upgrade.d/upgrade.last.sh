gitlab_version="12.9.1"

gitlab_x86_64_source_sha256="57f38c95abce48211a51fd6f58f3adc7aab367690f4e860f821e60b2e42a27f5"

gitlab_arm_source_sha256="37190935887455ee296f09c15b5ffce7c6077151ebdae45a0b5b175c22996695"

gitlab_filename="gitlab-ce-${gitlab_version}.deb"

# Action to do in case of failure of the package_check
package_check_action() {
	local sysctl_file="$final_path/embedded/cookbooks/package/resources/gitlab_sysctl.rb"
	if [ ! -f "$sysctl_file" ]; then
		sysctl_file="$final_path/embedded/cookbooks/package/resources/sysctl.rb"
	fi
	ynh_replace_string --match_string="command \"sysctl -e --system\"" --replace_string="command \"sysctl -e --system || true\"" --target_file=$sysctl_file
}
