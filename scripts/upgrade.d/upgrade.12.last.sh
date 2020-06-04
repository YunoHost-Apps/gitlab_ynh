gitlab_version="12.10.6"

# sha256sum found here: https://packages.gitlab.com/gitlab

gitlab_x86_64_debian_version="$(lsb_release -sc)"

if [ "$gitlab_x86_64_debian_version" = "buster" ]
then
	gitlab_x86_64_source_sha256="8305869246a70fb033fda3ba533f7b3459e7a044c0777dbc0215d868d73a22e6"
else
	gitlab_x86_64_source_sha256="f7c5a76bbb3cd192328be09832cce81d85847f22e97677c46087d5d1b8234cba"
fi

gitlab_arm_source_sha256="2e44c2c96cb6f381565f68814657b2ac73f11609601d16d4de6c539a53bb358f"

gitlab_filename="gitlab-ce-${gitlab_version}.deb"

# Action to do in case of failure of the package_check
package_check_action() {
	local sysctl_file="$final_path/embedded/cookbooks/package/resources/gitlab_sysctl.rb"
	ynh_replace_string --match_string="command \"sysctl -e \(.*\)\"" --replace_string="command \"sysctl -e \1 || true\"" --target_file=$sysctl_file
	
	sysctl_file="/opt/gitlab/embedded/cookbooks/package/recipes/sysctl.rb"
	ynh_replace_string --match_string="command \"sysctl -e \(.*\)\"" --replace_string="command \"sysctl -e \1 || true\"" --target_file=$sysctl_file
}
