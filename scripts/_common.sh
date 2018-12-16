#=================================================
# SET ALL CONSTANTS
#=================================================

app=$YNH_APP_INSTANCE_NAME
config_path="/etc/$app"
final_path="/opt/$app"

# Detect the system architecture to download the right tarball
# NOTE: `uname -m` is more accurate and universal than `arch`
# See https://en.wikipedia.org/wiki/Uname
if [ -n "$(uname -m | grep 64)" ]; then
	architecture="x86-64"
elif [ -n "$(uname -m | grep 86)" ]; then
	ynh_die "Gitlab is not compatible with x86 architecture"
elif [ -n "$(uname -m | grep arm)" ]; then
	architecture="arm"
else
	ynh_die "Unable to detect your achitecture, please open a bug describing \
        your hardware and the result of the command \"uname -m\"." 1
fi

config_nginx() {
    if [ "$path_url" != "/" ]
    then
        ynh_replace_string "^#sub_path_only" "" "../conf/nginx.conf"
    fi
    ynh_add_nginx_config
}

create_dir() {
    mkdir -p "$config_path"
}

config_gitlab() {
	gitlab_conf_path="$config_path/gitlab.rb"

    ynh_backup_if_checksum_is_different $gitlab_conf_path

	# Gitlab configuration
	cp -f ../conf/gitlab.rb $gitlab_conf_path

	ynh_replace_string "__GENERATED_EXTERNAL_URL__" "https://$domain${path_url%/}" $gitlab_conf_path
	ynh_replace_string "__PORT__" "$port" $gitlab_conf_path
	ynh_replace_string "__PORTUNICORN__" "$portUnicorn" $gitlab_conf_path

    ynh_store_file_checksum $gitlab_conf_path
}

remove_config_gitlab() {
	ynh_secure_remove "$config_path/gitlab.rb"
}

update_src_version() {
	source ./upgrade.d/upgrade.sh
	cp ../conf/arm.src.default ../conf/arm.src
	ynh_replace_string "__VERSION__" "$gitlab_version" "../conf/arm.src"
	ynh_replace_string "__SHA256_SUM__" "$gitlab_arm_source_sha256" "../conf/arm.src"

	cp ../conf/x86-64.src.default ../conf/x86-64.src
	ynh_replace_string "__VERSION__" "$gitlab_version" "../conf/x86-64.src"
	ynh_replace_string "__SHA256_SUM__" "$gitlab_x86_64_source_sha256" "../conf/x86-64.src"
}

setup_source () {
    local src_id=${1:-app} # If the argument is not given, source_id equals "app"

    # Load value from configuration file (see above for a small doc about this file
    # format)
    local src_url=$(grep 'SOURCE_URL=' "$YNH_CWD/../conf/${src_id}.src" | cut -d= -f2-)
    local src_sum=$(grep 'SOURCE_SUM=' "$YNH_CWD/../conf/${src_id}.src" | cut -d= -f2-)
    local src_sumprg=$(grep 'SOURCE_SUM_PRG=' "$YNH_CWD/../conf/${src_id}.src" | cut -d= -f2-)
    local src_format=$(grep 'SOURCE_FORMAT=' "$YNH_CWD/../conf/${src_id}.src" | cut -d= -f2-)
    local src_extract=$(grep 'SOURCE_EXTRACT=' "$YNH_CWD/../conf/${src_id}.src" | cut -d= -f2-)
    local src_in_subdir=$(grep 'SOURCE_IN_SUBDIR=' "$YNH_CWD/../conf/${src_id}.src" | cut -d= -f2-)
    local src_filename=$(grep 'SOURCE_FILENAME=' "$YNH_CWD/../conf/${src_id}.src" | cut -d= -f2-)

    # Default value
    src_sumprg=${src_sumprg:-sha256sum}
    src_in_subdir=${src_in_subdir:-true}
    src_format=${src_format:-tar.gz}
    src_format=$(echo "$src_format" | tr '[:upper:]' '[:lower:]')
    src_extract=${src_extract:-true}
    if [ "$src_filename" = "" ] ; then
        src_filename="${src_id}.${src_format}"
    fi
    local local_src="/opt/yunohost-apps-src/${YNH_APP_ID}/${src_filename}"

    if test -e "$local_src"
    then    # Use the local source file if it is present
        cp $local_src $src_filename
    else    # If not, download the source
        local out=`wget -nv -O $src_filename $src_url 2>&1` || ynh_print_err $out
    fi

    # Check the control sum
    echo "${src_sum} ${src_filename}" | ${src_sumprg} -c --status \
        || ynh_die "Corrupt source"

	dpkg -i $src_filename
}