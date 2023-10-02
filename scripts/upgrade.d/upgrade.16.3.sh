#!/bin/bash

gitlab_version="16.3.5"

# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_bullseye_source_sha256="80bf49ae846133f7a19267b494024a4010e64839829262ef5241f1fb585dc60c"
gitlab_x86_64_buster_source_sha256="ae216aa3e1831b928fe8a0a543cc3734e3ac3d6191d7eb5111f061f38b67e36c"

gitlab_arm64_bullseye_source_sha256="e38a2347f1b0c6af3dcac5cc5746b37db7059c9e8d4c82efaa90bcc7f8532f4e"
gitlab_arm64_buster_source_sha256="98bf7cc6ad9c339d90f6fd3e6ad90431b14c9817269278a5de6eff6a652264ca"

gitlab_arm_buster_source_sha256="b4fe665d35674a641755eb5d966cd4b05877c9149ba27a629960e82465432dda"
gitlab_arm_bullseye_source_sha256="b37e5318c90822d2ded46b604f7976c8b4a54764df5c937d48d6360d864531fe"

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
	if [ "$gitlab_debian_version" = "bullseye" ]
	then
		gitlab_source_sha256=$gitlab_arm_bullseye_source_sha256
	elif [ "$gitlab_debian_version" = "buster" ]
	then
		gitlab_source_sha256=$gitlab_arm_buster_source_sha256
	fi
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
