#!/bin/bash

#=================================================
# SET ALL CONSTANTS
#=================================================

pkg_dependencies="openssh-server"

#=================================================
# PACKAGE CHECK BYPASSING...
#=================================================

IS_PACKAGE_CHECK () {
	return $(env | grep -c container=lxc)
}

#=================================================
# BOOLEAN CONVERTER
#=================================================

bool_to_01 () {
	local var="$1"
	[ "$var" = "true" ] && var=1
	[ "$var" = "false" ] && var=0
	echo "$var"
}

bool_to_true_false () {
	local var="$1"
	[ "$var" = "1" ] && var=true
	[ "$var" = "0" ] && var=false
	echo "$var"
}

#=================================================
# WAIT
#=================================================
# Start (or other actions) a service,  print a log in case of failure and optionnaly wait until the service is completely started
#
# usage: ynh_systemd_action [-n service_name] [-a action] [ [-l "line to match"] [-p log_path] [-t timeout] [-e length] ]
# | arg: -n, --service_name= - Name of the service to start. Default : $app
# | arg: -a, --action=       - Action to perform with systemctl. Default: start
# | arg: -l, --line_match=   - Line to match - The line to find in the log to attest the service have finished to boot.
#                              If not defined it don't wait until the service is completely started.
#                              WARNING: When using --line_match, you should always add `ynh_clean_check_starting` into your
#                                `ynh_clean_setup` at the beginning of the script. Otherwise, tail will not stop in case of failure
#                                of the script. The script will then hang forever.
# | arg: -p, --log_path=     - Log file - Path to the log file. Default : /var/log/$app/$app.log
# | arg: -t, --timeout=      - Timeout - The maximum time to wait before ending the watching. Default : 300 seconds.
# | arg: -e, --length=       - Length of the error log : Default : 20
ynh_systemd_action() {
    # Declare an array to define the options of this helper.
    declare -Ar args_array=( [n]=service_name= [a]=action= [l]=line_match= [p]=log_path= [t]=timeout= [e]=length= )
    local service_name
    local action
    local line_match
    local length
    local log_path
    local timeout

    # Manage arguments with getopts
    ynh_handle_getopts_args "$@"

    local service_name="${service_name:-$app}"
    local action=${action:-start}
    local log_path="${log_path:-/var/log/$service_name/$service_name.log}"
    local length=${length:-20}
    local timeout=${timeout:-300}

    # Start to read the log
    if [[ -n "${line_match:-}" ]]
    then
        local templog="$(mktemp)"
        # Following the starting of the app in its log
        if [ "$log_path" == "systemd" ] ; then
            # Read the systemd journal
            journalctl --unit=$service_name --follow --since=-0 --quiet > "$templog" &
            # Get the PID of the journalctl command
            local pid_tail=$!
        else
            # Read the specified log file
            tail -F -n0 "$log_path" > "$templog" 2>&1 &
            # Get the PID of the tail command
            local pid_tail=$!
        fi
    fi

    ynh_print_info --message="${action^} the service $service_name"

    # Use reload-or-restart instead of reload. So it wouldn't fail if the service isn't running.
    if [ "$action" == "reload" ]; then
        action="reload-or-restart"
    fi

    systemctl $action $service_name \
        || ( journalctl --no-pager --lines=$length -u $service_name >&2 \
        ; test -e "$log_path" && echo "--" >&2 && tail --lines=$length "$log_path" >&2 \
        ; false )

    # Start the timeout and try to find line_match
    if [[ -n "${line_match:-}" ]]
    then
        local i=0
        for i in $(seq 1 $timeout)
        do
            # Read the log until the sentence is found, that means the app finished to start. Or run until the timeout
            if grep --quiet "$line_match" "$templog"
            then
                ynh_print_info --message="The service $service_name has correctly started."
                break
            fi
            if [ $i -eq 3 ]; then
                echo -n "Please wait, the service $service_name is ${action}ing" >&2
            fi
            if [ $i -ge 3 ]; then
                echo -n "." >&2
            fi
            sleep 1
        done
        if [ $i -ge 3 ]; then
            echo "" >&2
        fi
        if [ $i -eq $timeout ]
        then
            ynh_print_warn --message="The service $service_name didn't fully started before the timeout."
            ynh_print_warn --message="Please find here an extract of the end of the log of the service $service_name:"
            journalctl --no-pager --lines=$length -u $service_name >&2
            test -e "$log_path" && echo "--" >&2 && tail --lines=$length "$log_path" >&2
        fi
        ynh_clean_check_starting
    fi
}

# Clean temporary process and file used by ynh_check_starting
# (usually used in ynh_clean_setup scripts)
#
# usage: ynh_clean_check_starting
ynh_clean_check_starting () {
	# Stop the execution of tail.
	kill -s 15 $pid_tail 2>&1
	ynh_secure_remove "$templog" 2>&1
}