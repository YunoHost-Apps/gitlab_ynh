#!/bin/bash

gitlab_version="15.7.0"

# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_bullseye_source_sha256="4c346a5774313286a17b8fd082904ee49f5b0e809ad3f035d2892f12df239193"
gitlab_x86_64_buster_source_sha256="e152f9a813b19fd77c08fc878caa7c83695c0d0f91b907594ca1a446e04c21ed"

gitlab_arm64_bullseye_source_sha256="093df2c6d5c555d4206e9d3da90f5109fb216c25cee1289296a89a53eaca7717"
gitlab_arm64_buster_source_sha256="365285f23756d568f880aa82ae1ecf5da831fa84fb54ec3332be9c28ce1a76d7"

gitlab_arm_buster_source_sha256="13a57dc9c98787912e93dfd61c40e7f916079373280057175fc5722e21cbc7be"
gitlab_arm_bullseye_source_sha256="e47edd99dc25acc9a58e56e8878b06682f830e90a1d7c5d19cd6d186b9ad6a77"

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
		# If the version for arm doesn't exist, then use an older one
		if [ -z "$gitlab_arm_buster_source_sha256" ]; then
			gitlab_version="15.7.0"
			gitlab_arm_buster_source_sha256="13a57dc9c98787912e93dfd61c40e7f916079373280057175fc5722e21cbc7be"
		fi
		gitlab_source_sha256=$gitlab_arm_buster_source_sha256
	elif [ "$gitlab_debian_version" = "buster" ]
	then
		# If the version for arm doesn't exist, then use an older one
		if [ -z "$gitlab_arm_bullseye_source_sha256" ]; then
			gitlab_version="15.7.0"
			gitlab_arm_bullseye_source_sha256="e47edd99dc25acc9a58e56e8878b06682f830e90a1d7c5d19cd6d186b9ad6a77"
		fi
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
