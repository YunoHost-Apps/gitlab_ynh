#!/bin/bash

# /!\ This is a quick and dirty bash script, which does not respect the YNH format.

# This script will upgrade sha256sum, manifest, readme and config template
# /!\ before committing the modifications, check if nothing is broken if files
# Usage: ./upgrade-versions.sh path_to_upgrade_file version
# Example: ./upgrade-versions.sh scripts/upgrade.d/upgrade.last.sh 13.3.1

file=$(basename $1)
version=$2
current_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
gitlab_directory="$( cd "$( dirname "$current_dir/$1" )/../../" >/dev/null 2>&1 && pwd )"

sed -i -e "s/gitlab_version=\"[^0-9.]*[0-9.]*[0-9.]\"/gitlab_version=\"$version\"/" $gitlab_directory/scripts/upgrade.d/$file

# x86_64
for debian_version in "stretch" "buster"
do
    url=https://packages.gitlab.com/gitlab/gitlab-ce/packages/debian/$debian_version/gitlab-ce_$version-ce.0_amd64.deb

    new_sha256=$(curl -s $url | sed -n '/SHA256$/,/<\/tr>$/{ /SHA256$/d; /<\/tr>$/d; p; }' | cut -d$'\n' -f3 | xargs)

    echo url: $url
    echo sha256: $new_sha256

    sed -i -e "s/gitlab_x86_64_${debian_version}_source_sha256=\".*\"/gitlab_x86_64_${debian_version}_source_sha256=\"$new_sha256\"/" $gitlab_directory/scripts/upgrade.d/$file
done

# arm
for debian_version in "stretch" "buster"
do
    url=https://packages.gitlab.com/gitlab/raspberry-pi2/packages/raspbian/$debian_version/gitlab-ce_$version-ce.0_armhf.deb

    new_sha256=$(curl -s $url | sed -n '/SHA256$/,/<\/tr>$/{ /SHA256$/d; /<\/tr>$/d; p; }' | cut -d$'\n' -f3 | xargs)

    echo url: $url
    echo sha256: $new_sha256

    sed -i -e "s/gitlab_arm_${debian_version}_source_sha256=\".*\"/gitlab_arm_${debian_version}_source_sha256=\"$new_sha256\"/" $gitlab_directory/scripts/upgrade.d/$file
done

if [[ "$(basename $file)" == upgrade.last.sh ]]; then
    # Update manifest
    sed -i -e "s/\"version\": \"[^0-9.]*[0-9.]*[0-9.]\"/\"version\": \"$version~ynh1\"/" $gitlab_directory/manifest.json

    # Update readme
    sed -i -e "s/\*\*Shipped version:\*\* [^0-9.]*[0-9.]*[0-9.]/**Shipped version:** $version/" $gitlab_directory/README.md
    sed -i -e "s/\*\*Version incluse :\*\* [^0-9.]*[0-9.]*[0-9.]/**Version incluse :** $version/" $gitlab_directory/README_fr.md

    # Update gitlab.rb
    conf_file=$gitlab_directory/conf/gitlab.rb

    url=https://gitlab.com/gitlab-org/omnibus-gitlab/-/raw/$version+ce.0/files/gitlab-config-template/gitlab.rb.template
    
    header="################################################################################
################################################################################
##                             FOR YUNOHOST USERS                             ##
################################################################################
################################################################################

# Please do not modify this file, it will be reset with the next update.
# You can create or modify the file:
# /etc/gitlab/gitlab-persistent.rb
# and add all the configuration you want.
# Options you add in gitlab-presistent.rb will overide these one,
# but you can use options and documentations in this file to know what
# is it possible to do.

################################################################################
################################################################################
"

footer="
from_file '/etc/gitlab/gitlab-persistent.rb'"
    echo "$header" > $conf_file

    curl -s "$url" >> $conf_file

    echo "$footer" >> $conf_file

    # Change external url
    sed -i "s/external_url 'GENERATED_EXTERNAL_URL'/external_url '__GENERATED_EXTERNAL_URL__'/" $conf_file

    # Activate ldap
    sed -i "s/# gitlab_rails\['ldap_enabled'\] = .*/gitlab_rails['ldap_enabled'] = true/" $conf_file

    ldap_conf="
gitlab_rails['ldap_servers'] = YAML.load <<-'EOS' # remember to close this block with 'EOS' below
  main: # 'main' is the GitLab 'provider ID' of this LDAP server
    label: 'LDAP'
    host: 'localhost'
    port: 389
    uid: 'uid'
    encryption: 'plain' # \"start_tls\" or \"simple_tls\" or \"plain\"
    bind_dn: ''
    password: ''
    active_directory: false
    allow_username_or_email_login: false
    block_auto_created_users: false
    base: 'ou=users,dc=yunohost,dc=org'
    user_filter: ''
EOS"

    # Add ldap conf
    sed -i "/^# EOS/r "<(echo "$ldap_conf") $conf_file

    # Change ssh port
    sed -i "s/# gitlab_rails\['gitlab_shell_ssh_port'\] = 22/gitlab_rails['gitlab_shell_ssh_port'] = __SSH_PORT__/" $conf_file

    # Change puma settings
    sed -i "s/# puma\['worker_processes'\] = .*/puma['worker_processes'] = __PUMA_WORKER_PROCESSES__/" $conf_file
    sed -i "s/# puma\['min_threads'\] = .*/puma['min_threads'] = __PUMA_MIN_THREADS__/" $conf_file
    sed -i "s/# puma\['max_threads'\] = .*/puma['max_threads'] = __PUMA_MAX_THREADS__/" $conf_file
    sed -i "s/# puma\['port'\] = .*/puma['port'] = __PUMA_PORT__/" $conf_file

    # Change sidekiq settings
    sed -i "s/# sidekiq\['listen_port'\] = .*/sidekiq['listen_port'] = __SIDEKIQ_PORT__/" $conf_file

    # Change nginx settings
    sed -i "s/# nginx\['client_max_body_size'\] = .*/nginx['client_max_body_size'] = '__CLIENT_MAX_BODY_SIZE__'/" $conf_file
    sed -i "s/# nginx\['listen_port'\] = .*/nginx['listen_port'] = __PORT__/" $conf_file
    sed -i "s/# nginx\['listen_https'\] = .*/nginx['listen_https'] = false/" $conf_file
fi
