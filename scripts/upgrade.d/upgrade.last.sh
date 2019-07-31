gitlab_version="12.1.1"

gitlab_x86_64_source_sha256="e93360c6c8f403b1dd7e0d240c4abaaaf38624cc06d969281e5984011fbf1b45"

gitlab_arm_source_sha256="1aa935472832bfccf25a06864f72f01977af9b6313f2157ae277f1292147bfeb"

gitlab_filename="gitlab-ce-${gitlab_version}.deb"

# Action to do in case of failure of the package_check
package_check_action() {
		ynh_replace_string --match_string="command \"sysctl -e --system\"" --replace_string="command \"sysctl -e --system || true\"" --target_file="$final_path/embedded/cookbooks/package/resources/sysctl.rb"
}
