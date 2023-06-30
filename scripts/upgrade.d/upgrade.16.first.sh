#!/bin/bash

gitlab_version="16.0.0"

# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_bullseye_source_sha256="1c933d51068f67442de5b01d30869e0854c9199d24910cda43103d2fa49700b5"
gitlab_x86_64_buster_source_sha256="a91533c586e02441393fdb4560d5b7a9852beb339f683c26a9c85e098405e84c"

gitlab_arm64_bullseye_source_sha256="90425b49427b46d8c5dbb09187baf76dbdf372f177f27d6e31b9717cd60849cc"
gitlab_arm64_buster_source_sha256="1393b8fb9498f4ead75aad69d89f9ba6e9281f3619f071f3efeebf72d2d6829f"

gitlab_arm_buster_source_sha256="821bf4d6cf9f12373dc89d7ec757f3546a94a339ad5c1f044d102b9468e840b6"
gitlab_arm_bullseye_source_sha256="2bb0c4145d467c2d79a9067f090ace1b967318a49dc34e969d5abc06040d111e"

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
