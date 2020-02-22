gitlab_version="12.8.0"

gitlab_x86_64_source_sha256="bc8a47a29a16fbeb77163a9fb6ae77f556504f76c2617ca7c5985752f30c84fe"

gitlab_arm_source_sha256="89d0db6632fe74b052708c6a641bb8d9b192e343e89cd91b87468265eca22ba0"

gitlab_filename="gitlab-ce-${gitlab_version}.deb"

# Action to do in case of failure of the package_check
package_check_action() {
	local sysctl_file="$final_path/embedded/cookbooks/package/resources/gitlab_sysctl.rb"
	if [ ! -f "$sysctl_file" ]; then
		sysctl_file="$final_path/embedded/cookbooks/package/resources/sysctl.rb"
	fi
	ynh_replace_string --match_string="command \"sysctl -e --system\"" --replace_string="command \"sysctl -e --system || true\"" --target_file=$sysctl_file
}
