#!/bin/bash

gitlab_version="14.10.3"

# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_bullseye_source_sha256="6e9365b30d0d4efeebb84be43acb899fbd2e1fb077c86d66f18845b10789b63a"
gitlab_x86_64_buster_source_sha256="897c76a8df2a744ac9788e703a054e857366ec36f6aa7208ee130f89413eeb52"

gitlab_arm64_bullseye_source_sha256="6b8fd05d4a9477272343f7e821fb713d4c85d015358352a0f45702dbf48d672a"
gitlab_arm64_buster_source_sha256="23e6393ed07254c3d34b09cdd8aa34af107ee7934471fe439315ef0249b45db8"

gitlab_arm_buster_source_sha256="223d3081f660739363d4c240e229288f95392593b68c54afe5b18ca8fc6908c3"

architecture=$(ynh_app_setting_get --app="$app" --key=architecture)

if [ "$architecture" = "x86-64" ]; then
	if [ "$gitlab_debian_version" = "bullseye" ]
	then
		gitlab_source_sha256=$gitlab_x86_64_bullseye_source_sha256
	elif [ "$gitlab_debian_version" = "buster" ]
	then
		gitlab_source_sha256=$gitlab_x86_64_buster_source_sha256
	fi
elif [ "$architecture" = "arm64" ]; then
	if [ "$gitlab_debian_version" = "bullseye" ]
	then
		gitlab_source_sha256=$gitlab_arm64_bullseye_source_sha256
	elif [ "$gitlab_debian_version" = "buster" ]
	then
		gitlab_source_sha256=$gitlab_arm64_buster_source_sha256
	fi
elif [ "$architecture" = "arm" ]; then
	# If the version for arm doesn't exist, then use an older one
	if [ -z "$gitlab_arm_buster_source_sha256" ]; then
		gitlab_version="14.10.3"
		gitlab_arm_buster_source_sha256="223d3081f660739363d4c240e229288f95392593b68c54afe5b18ca8fc6908c3"
	fi
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
