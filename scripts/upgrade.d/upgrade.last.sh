gitlab_version="12.8.5"

gitlab_x86_64_source_sha256="ef9a55ca32f0d2450ce34f355debc01f3fcebc48ed389fd3ac82c76773bf7ec7"

gitlab_arm_source_sha256="0fcb4b715430ac8b94eff186909d59de50188e33957ffdb6f30b11ca87bd80a6"

gitlab_filename="gitlab-ce-${gitlab_version}.deb"

# Action to do in case of failure of the package_check
package_check_action() {
	local sysctl_file="$final_path/embedded/cookbooks/package/resources/gitlab_sysctl.rb"
	if [ ! -f "$sysctl_file" ]; then
		sysctl_file="$final_path/embedded/cookbooks/package/resources/sysctl.rb"
	fi
	ynh_replace_string --match_string="command \"sysctl -e --system\"" --replace_string="command \"sysctl -e --system || true\"" --target_file=$sysctl_file
}
