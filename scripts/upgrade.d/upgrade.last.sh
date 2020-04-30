gitlab_version="12.10.1"

# sha256sum found here: https://packages.gitlab.com/gitlab

if [ "$(lsb_release -sc)" = "buster" ]
then
	gitlab_x86_64_source_sha256="4efd4599cecbcdbe4c03acabf8a678da7a1c0f3fe44270dc115128f87704a29c"
else
	gitlab_x86_64_source_sha256="114e616b8fad94efcd7bcecd7b69d49c42384d6599ff49809c1951e3007afc9c"
fi

gitlab_x86_64_debian_version="$(lsb_release -sc)"

gitlab_arm_source_sha256="cc52de7777e0a970be20bc3386144a2d2bb0e9aaaa8906e567a4ab0cd638288e"

gitlab_filename="gitlab-ce-${gitlab_version}.deb"

# Action to do in case of failure of the package_check
package_check_action() {
	local sysctl_file="$final_path/embedded/cookbooks/package/resources/gitlab_sysctl.rb"
	ynh_replace_string --match_string="command \"sysctl -e \(.*\)\"" --replace_string="command \"sysctl -e \1 || true\"" --target_file=$sysctl_file
	
	sysctl_file="/opt/gitlab/embedded/cookbooks/package/recipes/sysctl.rb"
	ynh_replace_string --match_string="command \"sysctl -e \(.*\)\"" --replace_string="command \"sysctl -e \1 || true\"" --target_file=$sysctl_file
}
