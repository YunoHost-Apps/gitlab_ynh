#!/bin/bash

#=================================================
# SET ALL CONSTANTS
#=================================================

pkg_dependencies="openssh-server"

#=================================================
# EXPERIMENTAL HELPERS
#=================================================

# Add swap
#
# usage: ynh_add_swap --size=SWAP in Mb
# | arg: -s, --size= - Amount of SWAP to add in Mb.
ynh_add_swap () {
	# Declare an array to define the options of this helper.
	declare -Ar args_array=( [s]=size= )
	local size
	# Manage arguments with getopts
	ynh_handle_getopts_args "$@"

	local swap_max_size=$(( $size * 1024 ))

	local free_space=$(df --output=avail / | sed 1d)
	# Because we don't want to fill the disk with a swap file, divide by 2 the available space.
	local usable_space=$(( $free_space / 2 ))

 	SD_CARD_CAN_SWAP=${SD_CARD_CAN_SWAP:-0}

	# Swap on SD card only if it's is specified
	if ynh_is_main_device_a_sd_card && [ "$SD_CARD_CAN_SWAP" == "0" ]
	then
		ynh_print_warn --message="The main mountpoint of your system '/' is on an SD card, swap will not be added to prevent some damage of this one, but that can cause troubles for the app $app. If you still want activate the swap, you can relaunch the command preceded by 'SD_CARD_CAN_SWAP=1'"
		return
	fi

	# Compare the available space with the size of the swap.
	# And set a acceptable size from the request
	if [ $usable_space -ge $swap_max_size ]
	then
		local swap_size=$swap_max_size
	elif [ $usable_space -ge $(( $swap_max_size / 2 )) ]
	then
		local swap_size=$(( $swap_max_size / 2 ))
	elif [ $usable_space -ge $(( $swap_max_size / 3 )) ]
	then
		local swap_size=$(( $swap_max_size / 3 ))
	elif [ $usable_space -ge $(( $swap_max_size / 4 )) ]
	then
		local swap_size=$(( $swap_max_size / 4 ))
	else
		echo "Not enough space left for a swap file" >&2
		local swap_size=0
	fi

	# If there's enough space for a swap, and no existing swap here
	if [ $swap_size -ne 0 ] && [ ! -e /swap_$app ]
	then
		# Preallocate space for the swap file, fallocate may sometime not be used, use dd instead in this case
		if ! fallocate -l ${swap_size}K /swap_$app
		then
			dd if=/dev/zero of=/swap_$app bs=1024 count=${swap_size}
		fi
		chmod 0600 /swap_$app
		# Create the swap
		mkswap /swap_$app
		# And activate it
		swapon /swap_$app
		# Then add an entry in fstab to load this swap at each boot.
		echo -e "/swap_$app swap swap defaults 0 0 #Swap added by $app" >> /etc/fstab
	fi
}

ynh_del_swap () {
	# If there a swap at this place
	if [ -e /swap_$app ]
	then
		# Clean the fstab
		sed -i "/#Swap added by $app/d" /etc/fstab
		# Desactive the swap file
		swapoff /swap_$app
		# And remove it
		rm /swap_$app
	fi
}

# Check if the device of the main mountpoint "/" is an SD card
#
# [internal]
#
# return 0 if it's an SD card, else 1
ynh_is_main_device_a_sd_card () {
	local main_device=$(lsblk --output PKNAME --noheadings $(findmnt / --nofsroot --uniq --output source --noheadings --first-only))

	if echo $main_device | grep --quiet "mmc" && [ $(tail -n1 /sys/block/$main_device/queue/rotational) == "0" ]
	then
		return 0
	else
		return 1
	fi
}

# Check the amount of available RAM
#
# usage: ynh_check_ram [--required=RAM required in Mb] [--no_swap|--only_swap] [--free_ram]
# | arg: -r, --required= - Amount of RAM required in Mb. The helper will return 0 is there's enough RAM, or 1 otherwise.
# If --required isn't set, the helper will print the amount of RAM, in Mb.
# | arg: -s, --no_swap   - Ignore swap
# | arg: -o, --only_swap - Ignore real RAM, consider only swap.
# | arg: -f, --free_ram  - Count only free RAM, not the total amount of RAM available.
ynh_check_ram () {
	# Declare an array to define the options of this helper.
	declare -Ar args_array=( [r]=required= [s]=no_swap [o]=only_swap [f]=free_ram )
	local required
	local no_swap
	local only_swap
	# Manage arguments with getopts
	ynh_handle_getopts_args "$@"
	required=${required:-}
	no_swap=${no_swap:-0}
	only_swap=${only_swap:-0}

	local total_ram=$(vmstat --stats --unit M | grep "total memory" | awk '{print $1}')
	local total_swap=$(vmstat --stats --unit M | grep "total swap" | awk '{print $1}')
	local total_ram_swap=$(( total_ram + total_swap ))

	local free_ram=$(vmstat --stats --unit M | grep "free memory" | awk '{print $1}')
	local free_swap=$(vmstat --stats --unit M | grep "free swap" | awk '{print $1}')
	local free_ram_swap=$(( free_ram + free_swap ))

	# Use the total amount of ram
	local ram=$total_ram_swap
	if [ $free_ram -eq 1 ]
	then
		# Use the total amount of free ram
		ram=$free_ram_swap
		if [ $no_swap -eq 1 ]
		then
			# Use only the amount of free ram
			ram=$free_ram
		elif [ $only_swap -eq 1 ]
		then
			# Use only the amount of free swap
			ram=$free_swap
		fi
	else
		if [ $no_swap -eq 1 ]
		then
			# Use only the amount of free ram
			ram=$total_ram
		elif [ $only_swap -eq 1 ]
		then
			# Use only the amount of free swap
			ram=$total_swap
		fi
	fi

	if [ -n "$required" ]
	then
		# Return 1 if the amount of ram isn't enough.
		if [ $ram -lt $required ]
		then
			return 1
		else
			return 0
		fi

	# If no RAM is required, return the amount of available ram.
	else
		echo $ram
	fi
}
