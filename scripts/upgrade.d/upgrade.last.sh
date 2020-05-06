gitlab_version="12.10.3"

# sha256sum found here: https://packages.gitlab.com/gitlab

gitlab_x86_64_debian_version="$(lsb_release -sc)"

if [ "$gitlab_x86_64_debian_version" = "buster" ]
then
	gitlab_x86_64_source_sha256="dcb8b3b770aa7645f6485d877915e4075da214185f631560df270cfe6de89f0d"
else
	gitlab_x86_64_source_sha256="f25c1b15a64eb74209185074363f58cc9082102210c7ef7434a6c82f39b1ffb6"
fi

gitlab_arm_source_sha256="898bd6492f04846113babe7db95b82dfcf1cf6974fe63482231d8a723e2928fb"

gitlab_filename="gitlab-ce-${gitlab_version}.deb"

# Action to do in case of failure of the package_check
package_check_action() {
	local sysctl_file="$final_path/embedded/cookbooks/package/resources/gitlab_sysctl.rb"
	ynh_replace_string --match_string="command \"sysctl -e \(.*\)\"" --replace_string="command \"sysctl -e \1 || true\"" --target_file=$sysctl_file
	
	sysctl_file="/opt/gitlab/embedded/cookbooks/package/recipes/sysctl.rb"
	ynh_replace_string --match_string="command \"sysctl -e \(.*\)\"" --replace_string="command \"sysctl -e \1 || true\"" --target_file=$sysctl_file
}
