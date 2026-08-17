#!/bin/bash

# Action to do in case of failure of the package_check
package_check_action() {
	ynh_backup_if_checksum_is_different "$config_path/gitlab.rb"
	cat <<EOF >> "$config_path/gitlab.rb"
# Last chance to fix Gitlab
package['modify_kernel_parameters'] = false
EOF
	ynh_store_file_checksum "$config_path/gitlab.rb"
}

# Restart GitLab through runit, and wait for Puma to listen again
#
# usage: gitlab_restart [service]
# | arg: service - the service to restart, or all of them if omitted
gitlab_restart() {
	local service="${1:-}"
	local log_path="/var/log/$app/puma/current"
	local timeout=300

	# Only Puma tells us in its log when it's back up
	if [ -n "$service" ] && [ "$service" != "puma" ]; then
		gitlab-ctl restart "$service"
		return
	fi

	local templog="$(mktemp)"
	tail --follow=name --retry --lines=0 "$log_path" > "$templog" 2>&1 &
	local pid_tail=$!

	if [ "$service" == "puma" ]; then
		# Puma stops slower than runit is willing to wait, and has no check
		# script, so start returns as soon as it is spawned
		gitlab-ctl kill puma
		gitlab-ctl start puma
	else
		gitlab-ctl restart || true
	fi

	local i
	for i in $(seq 1 $timeout)
	do
		if grep --quiet "Listening on http://127.0.0.1:$port_puma" "$templog"; then
			break
		fi
		if [ "$i" -eq 30 ]; then
			ynh_print_info "Waiting for GitLab to restart (this may take some time)"
		fi
		sleep 1
	done

	kill "$pid_tail" 2>/dev/null
	ynh_safe_rm "$templog"

	if [ "$i" -eq "$timeout" ]; then
		ynh_print_warn "GitLab did not restart before the timeout"
		tail --lines=20 "$log_path" >&2
		return 1
	fi
}
