#!/bin/bash

gitlab_version="17.4.2"

# Upgrade path: https://gitlab-com.gitlab.io/support/toolbox/upgrade-path/
# sha256sum found here: https://packages.gitlab.com/gitlab
gitlab_debian_version="$(lsb_release -sc)"

gitlab_x86_64_bookworm_source_sha256="d54ad5ae77a7db32874ca5e3d24d42c16281badad9831034501121ed88b8ebcf"
gitlab_x86_64_bullseye_source_sha256="e25dbf744bb2f2e3f53653dc711a519d6de8abf20f58cdcba721566230f8bf0e"
gitlab_x86_64_buster_source_sha256="2017dd40c39a2d71dcce67386016870b160da9167ef999ab9af141cde85143b4"

gitlab_arm64_bookworm_source_sha256="3912573b9ac26dfc15035cdd94891bca16d174652562f97840eb161494141aaf"
gitlab_arm64_bullseye_source_sha256="bb243385613855b83e2bf17dd6c6c68ec119f1112499afdebeb86678b35b073a"
gitlab_arm64_buster_source_sha256="21ad6899e5ff4dfd0eeb4868dc2a2f61141c667e488a235d112cea79673c01c8"

gitlab_arm_bookworm_source_sha256="2b9de492ba41879c0d719d3c60e32c3602644cd4183ba53cfdd8671fc353e35a"
gitlab_arm_bullseye_source_sha256="3dbb720136c0f0e65d94690cb808ce46239d972a459309d59a2d596d3d78c091"
gitlab_arm_buster_source_sha256="6bf9b6997886ee4a02ba2523ba03688614cdccc092d37112cd29efa6355ca45d"

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
