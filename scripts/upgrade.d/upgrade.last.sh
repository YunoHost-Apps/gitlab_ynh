gitlab_version="12.4.1"

gitlab_x86_64_source_sha256="c648d9b00ed5070a3cae6df508479380757040682ac71b7e43fb6466b1c2bb38"

gitlab_arm_source_sha256="9634c287b75e849c7424c1bbf9507ad7f63bef14f340c2ce156e39e64a38cea5"

gitlab_filename="gitlab-ce-${gitlab_version}.deb"

# Action to do in case of failure of the package_check
package_check_action() {
	local sysctl_file="$final_path/embedded/cookbooks/package/resources/gitlab_sysctl.rb"
	if [ ! -f "$sysctl_file" ]; then
		sysctl_file="$final_path/embedded/cookbooks/package/resources/sysctl.rb"
	fi
	ynh_replace_string --match_string="command \"sysctl -e --system\"" --replace_string="command \"sysctl -e --system || true\"" --target_file=$sysctl_file
}
