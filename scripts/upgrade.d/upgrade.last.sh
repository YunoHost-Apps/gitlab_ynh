gitlab_version="12.0.3"

gitlab_x86_64_source_sha256="9e2dcb0e4e3ca3c230d43c6b8580d77c2c716f3c6d1055739f175ead20d83678"

gitlab_arm_source_sha256="992710fd2c4076961f03633cb6b56331f7ade63a6869c47c2ce28995f8b43893"

gitlab_filename="gitlab-ce-${gitlab_version}.deb"

# Action to do in case of failure of the package_check
package_check_action() {
		ynh_replace_string --match_string="command \"sysctl -e --system\"" --replace_string="command \"sysctl -e --system || true\"" --target_file="$final_path/embedded/cookbooks/package/resources/sysctl.rb"
}
