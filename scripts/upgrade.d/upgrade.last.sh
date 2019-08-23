gitlab_version="12.2.0"

gitlab_x86_64_source_sha256="c483581545891e65eafcc15b6cf2f620b8f5df34e4e26fb12da984556196ebeb"

gitlab_arm_source_sha256="231d115b3c0a459b9ee3cc47f432755cfacf2925190c996a59923c061eddf6cb"

gitlab_filename="gitlab-ce-${gitlab_version}.deb"

# Action to do in case of failure of the package_check
package_check_action() {
	local sysctl_file="$final_path/embedded/cookbooks/package/resources/gitlab_sysctl.rb"
	if [ ! -f "$sysctl_file" ]; then
		sysctl_file="$final_path/embedded/cookbooks/package/resources/sysctl.rb"
	fi
	ynh_replace_string --match_string="command \"sysctl -e --system\"" --replace_string="command \"sysctl -e --system || true\"" --target_file=$sysctl_file
}
