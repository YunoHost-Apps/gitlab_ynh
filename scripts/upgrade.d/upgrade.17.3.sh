#!/bin/bash

gitlab_version="17.3.3"

# Upgrade path: https://gitlab-com.gitlab.io/support/toolbox/upgrade-path/
# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_bookworm_source_sha256="f35c33c8565b38ff0e6f1f254378f48d8759e320a0a17d5fda90780af07e92f2"
gitlab_x86_64_bullseye_source_sha256="648b0c909693840fdfd52976f20e1d7f4a9c94222db61aa5bcdb588f2254fdbe"
gitlab_x86_64_buster_source_sha256="c9619432fb610516e26cfc21904ccefb55b6e27a6891d7dd0c3980c433c8da94"

gitlab_arm64_bookworm_source_sha256="d13dae3ec17cd28122369e9396ce9825bae7f1fd2f3940f5d490da5b9c4346d1"
gitlab_arm64_bullseye_source_sha256="ea47c085560fb399a8e547ec3b6d992521320bf437047bffb6bc879d0d41dcd5"
gitlab_arm64_buster_source_sha256="ff0576e17fcd1957be039dceafecd5bffb4ea411b33b5442bdc37bed0d9a79b1"

gitlab_arm_bookworm_source_sha256="7d4e1e301daa99f68e8e32a35e10fc68c6c0d0e6fd013b78ad6aba212b9baf75"
gitlab_arm_bullseye_source_sha256="aa77a46294e9ed0cc0ff012617ad42705a4c320aee121c762f5cf1da6f4916aa"
gitlab_arm_buster_source_sha256="5bfc916cd0972fe20e82e50a4df7d265efd1393c1e6391f37ce421babd17fe98"

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
	elif [ "$gitlab_debian_version" = "buster" ]
	then
		gitlab_source_sha256=$gitlab_x86_64_buster_source_sha256
	fi
elif [ "$architecture" = "arm64" ]; then
	if [ "$gitlab_debian_version" = "bookworm" ]
	then
		gitlab_source_sha256=$gitlab_arm64_bookworm_source_sha256
	elif [ "$gitlab_debian_version" = "bullseye" ]
	then
		gitlab_source_sha256=$gitlab_arm64_bullseye_source_sha256
	elif [ "$gitlab_debian_version" = "buster" ]
	then
		gitlab_source_sha256=$gitlab_arm64_buster_source_sha256
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
