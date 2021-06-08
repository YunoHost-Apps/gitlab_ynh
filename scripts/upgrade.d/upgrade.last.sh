#!/bin/bash

gitlab_version="13.12.3"

# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="buster"

gitlab_x86_64_buster_source_sha256="717a5dae4852afe940edce46fdbc5d4b029ed457607fe92b308a8c98b8feab7c"

gitlab_arm64_buster_source_sha256="0d6aa4c77b299b7ec933bd2ca53fce95771d9f1f5828dbbff11daa799ce04eee"

gitlab_arm_buster_source_sha256="4995cb439dd652f64446625fafb4afd1b1970327068029f7d9e99035a699d475"

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
