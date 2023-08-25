#!/bin/bash

gitlab_version="15.11.13"

# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_bullseye_source_sha256="5c3cbe468cca4f1c90a53d59ffaeac147cb72c46eb5c48c4a3c235217c66d28d"
gitlab_x86_64_buster_source_sha256="f8fd655c4e034c79ce2b2920f36b9a9aa6e796fde9861467e74e9de0fe87cabd"

gitlab_arm64_bullseye_source_sha256="82dbb4b1084b6599b4cc01b085a70ae0a53b837be10573696ddd9dc51f337a65"
gitlab_arm64_buster_source_sha256="725176c1dded56fc97ebf9c5eb4f1a1866302e5609c45934228a0226d919bb3e"

gitlab_arm_buster_source_sha256="562a6db5270847d5aafb7e6c216746b9b9da22e5074bd431b6bd6444f89a768f"
gitlab_arm_bullseye_source_sha256="cdd8cad053f8faa6cc33efda5e77e8698eec0c019c20b316ac19c5cb008022b0"

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
