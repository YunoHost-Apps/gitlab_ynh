#!/bin/bash

gitlab_version="13.12.1"

# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="buster"

gitlab_x86_64_buster_source_sha256="53f52edd4930c212398658ea48e2a2478d22e65bc63f0fc9d03bca8a25738fed"

gitlab_arm64_buster_source_sha256="a5e5dca6d47e53b0522c29d978b3f5f8bd23528acde46d13d559511147bc1b28"

gitlab_arm_buster_source_sha256="7bc001c164dc082e5a5887f3d8fb1234d9bfc474ddc21142f4103c9ddc567d03"

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
