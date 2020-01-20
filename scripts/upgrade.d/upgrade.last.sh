gitlab_version="12.6.4"

gitlab_x86_64_source_sha256="9976a0e4c2c5022e5344f53f2303cc10bfd97a4d892b22422866196fe7d41d90"

gitlab_arm_source_sha256="514d222b210e6d629182c889d1dd8121beeb544b7f06289cf3903da79857f4c1"

gitlab_filename="gitlab-ce-${gitlab_version}.deb"

# Action to do in case of failure of the package_check
package_check_action() {
	local sysctl_file="$final_path/embedded/cookbooks/package/resources/gitlab_sysctl.rb"
	if [ ! -f "$sysctl_file" ]; then
		sysctl_file="$final_path/embedded/cookbooks/package/resources/sysctl.rb"
	fi
	ynh_replace_string --match_string="command \"sysctl -e --system\"" --replace_string="command \"sysctl -e --system || true\"" --target_file=$sysctl_file
}
