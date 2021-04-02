#!/bin/bash

gitlab_version="13.10.0"

# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="buster"

gitlab_x86_64_buster_source_sha256="85a02b3fa8bfa5ec2a69ef039e2dd787ad317d920c05b697be314e3e74542190"

gitlab_arm64_buster_source_sha256="fb7a1e4ef95651211f4327cbe1680bdd59c039365f83f1d47a319176f796f824"

gitlab_arm_buster_source_sha256="1613a02e2925af265ddbdf809d3614cc609d7dc037a82f6bdcbf285bf76494dd"

architecture=$(ynh_app_setting_get --app="$app" --key=architecture)

if [ "$architecture" = "x86-64" ]; then
	gitlab_source_sha256=$gitlab_x86_64_buster_source_sha256
elif [ "$architecture" = "arm64" ]; then
	gitlab_source_sha256=$gitlab_arm64_buster_source_sha256
elif [ "$architecture" = "arm" ]; then
	gitlab_source_sha256=$gitlab_arm_buster_source_sha256
fi

gitlab_filename="gitlab-ce-${gitlab_version}.deb"

# Action to do in case of failure of the package_check
package_check_action() {
	ynh_backup_if_checksum_is_different --file="$config_path/gitlab.rb"
	cat <<EOF >> "$config_path/gitlab.rb"
# Last chance to fix Gitlab
package['modify_kernel_parameters'] = false
EOF
	ynh_store_file_checksum --file="$config_path/gitlab.rb"
}
