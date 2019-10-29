gitlab_version="12.4.0"

gitlab_x86_64_source_sha256="a8e84fe14b8ea1e63b6746478475f1253528d25414f5dd4538cb0f229ed42d82"

gitlab_arm_source_sha256="ab5ae257dc3b26f463a5afaf1344f4218fb545080e8e9a0f071d8cd59da2f259"

gitlab_filename="gitlab-ce-${gitlab_version}.deb"

# Action to do in case of failure of the package_check
package_check_action() {
	local sysctl_file="$final_path/embedded/cookbooks/package/resources/gitlab_sysctl.rb"
	if [ ! -f "$sysctl_file" ]; then
		sysctl_file="$final_path/embedded/cookbooks/package/resources/sysctl.rb"
	fi
	ynh_replace_string --match_string="command \"sysctl -e --system\"" --replace_string="command \"sysctl -e --system || true\"" --target_file=$sysctl_file
}
