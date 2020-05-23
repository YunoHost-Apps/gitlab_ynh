gitlab_version="11.11.5"

# There is no buster version for gitlab 11.X
gitlab_x86_64_debian_version="stretch"

gitlab_x86_64_source_sha256="1ee3d6e8d2cc198f5466de0884c03f6016299db24859126af9a191501dbdef10"

gitlab_arm_source_sha256="366e12b1f3d3b1694fcb6f13da9de908360ba93f75768d97e8d01e61e8652705"

gitlab_filename="gitlab-ce-${gitlab_version}.deb"

# Action to do in case of failure of the package_check
package_check_action() {
	local sysctl_file="$final_path/embedded/cookbooks/package/resources/sysctl.rb"
	ynh_replace_string --match_string="command \"sysctl -e \(.*\)\"" --replace_string="command \"sysctl -e \1 || true\"" --target_file=$sysctl_file
}

