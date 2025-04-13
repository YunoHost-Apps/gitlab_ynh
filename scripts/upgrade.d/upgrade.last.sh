#!/bin/bash

gitlab_version="17.10.4"

# Upgrade path: https://gitlab-com.gitlab.io/support/toolbox/upgrade-path/
# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_bookworm_source_sha256="a50ee3242d389967f8194637508e68813585131fd864de4057599c90fbe67006"
gitlab_x86_64_bullseye_source_sha256="cb5ca43ae6a52058cbf85f0e4118221ca27099a5e42d0b89b2431a04906e1d55"

gitlab_arm64_bookworm_source_sha256="eefed395dad73bb0ec1ac8fbb1042466333d2504126a33bb61f17b3a8a1fdd36"
gitlab_arm64_bullseye_source_sha256="53a560c3f9b4f50c703cd61ca182f25d8153eb9b056dc257a94f951d192a4bd0"

gitlab_arm_bookworm_source_sha256="d4a41de595a2c09aca94aa269335f78e1b71d50dc62ff9e6b4bf80f8d4d73b0c"
gitlab_arm_bullseye_source_sha256="07c1e23f71e50ec4f19480e61acf9ce80869bc323c156d1ec2df8f7facf2eb50"

architecture=$(ynh_app_setting_get --app="$app" --key=architecture)

# Evaluating indirect/reference variables https://mywiki.wooledge.org/BashFAQ/006#Indirection 
# ref=gitlab_${architecture}_${gitlab_debian_version}_source_sha256
# gitlab_source_sha256=${!ref}

if [ "$architecture" = "x86-64" ]; then
	if [ "$gitlab_debian_version" = "bookworm" ]
	then
		gitlab_source_sha256=$gitlab_x86_64_bookworm_source_sha256
	elif [ "$gitlab_debian_version" = "bullseye" ]
	then
		gitlab_source_sha256=$gitlab_x86_64_bullseye_source_sha256
	fi
elif [ "$architecture" = "arm64" ]; then
	if [ "$gitlab_debian_version" = "bookworm" ]
	then
		gitlab_source_sha256=$gitlab_arm64_bookworm_source_sha256
	elif [ "$gitlab_debian_version" = "bullseye" ]
	then
		gitlab_source_sha256=$gitlab_arm64_bullseye_source_sha256
	fi
elif [ "$architecture" = "arm" ]; then
	if [ "$gitlab_debian_version" = "bookworm" ]
	then
		gitlab_source_sha256=$gitlab_arm_bookworm_source_sha256
		if [ -z "$gitlab_arm_bookworm_source_sha256" ]
		then
			gitlab_source_sha256=$gitlab_arm_bullseye_source_sha256
		fi
	elif [ "$gitlab_debian_version" = "bullseye" ]
	then
		gitlab_source_sha256=$gitlab_arm_bullseye_source_sha256
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
