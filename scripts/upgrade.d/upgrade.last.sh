gitlab_version="12.7.6"

gitlab_x86_64_source_sha256="b2452d5d83120b4226a3a26c4e1fa8a0cb2ac62833d971f32b3d844c70073a44"

gitlab_arm_source_sha256="1ca5be46e17784119b6714e5a5f8f0688da11f493f8a1cd847e47ef7c58c0554"

gitlab_filename="gitlab-ce-${gitlab_version}.deb"

# Action to do in case of failure of the package_check
package_check_action() {
	local sysctl_file="$final_path/embedded/cookbooks/package/resources/gitlab_sysctl.rb"
	if [ ! -f "$sysctl_file" ]; then
		sysctl_file="$final_path/embedded/cookbooks/package/resources/sysctl.rb"
	fi
	ynh_replace_string --match_string="command \"sysctl -e --system\"" --replace_string="command \"sysctl -e --system || true\"" --target_file=$sysctl_file
}
