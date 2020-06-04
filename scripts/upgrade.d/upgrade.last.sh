gitlab_version="13.0.4"

# sha256sum found here: https://packages.gitlab.com/gitlab

gitlab_x86_64_debian_version="$(lsb_release -sc)"

if [ "$gitlab_x86_64_debian_version" = "buster" ]
then
	gitlab_x86_64_source_sha256="a98cdf17d2231b4ef1b4a4e2b743b0701aab6702552fad9c60d92e2c2928fc43"
else
	gitlab_x86_64_source_sha256="e806c80281f7b5b7c00a7c342072b137aa1fdf06db934855babee4d168c2fd2b"
fi

gitlab_arm_source_sha256="5e85e991bb1554ce5fa967e978c0b6870675df3cec2a99e8c4c5dabc28b94967"

gitlab_filename="gitlab-ce-${gitlab_version}.deb"

# Action to do in case of failure of the package_check
package_check_action() {
	local sysctl_file="$final_path/embedded/cookbooks/package/resources/gitlab_sysctl.rb"
	ynh_replace_string --match_string="command \"sysctl -e \(.*\)\"" --replace_string="command \"sysctl -e \1 || true\"" --target_file=$sysctl_file
	
	sysctl_file="/opt/gitlab/embedded/cookbooks/package/recipes/sysctl.rb"
	ynh_replace_string --match_string="command \"sysctl -e \(.*\)\"" --replace_string="command \"sysctl -e \1 || true\"" --target_file=$sysctl_file
}
