#!/bin/sh
#
# Description	: local
# Authors	: jianjun jiang - jjjstudio@gmail.com
# Version	: 0.01
# Path		: /scripts/local
# Notes		: 


# echo the title.
echo "[scripts] Create /scripts/local ...";

# The contents of /scripts/local file.
cat > $INITRD_DIR/scripts/local << "EOF"
# Local filesystem mounting			-*- shell-script -*-

# Parameter: device node to check
# Echos fstype to stdout
# Return value: indicates if an fs could be recognized
get_fstype ()
{
	local FS FSTYPE FSSIZE RET
	FS="${1}"

	# vol_id has a more complete list of file systems,
	# but fstype is more robust
	eval $(fstype "${FS}" 2> /dev/null)

	if [ -z "${FSTYPE}" ]; then
		FSTYPE="unknown"
	fi

	if [ "$FSTYPE" = "unknown" ] && [ -x /lib/udev/vol_id ]; then
		FSTYPE=$(/lib/udev/vol_id -t "${FS}" 2> /dev/null)
	fi
	RET=$?

	if [ -z "${FSTYPE}" ]; then
		FSTYPE="unknown"
	fi

	echo "${FSTYPE}"
	return ${RET}
}

root_missing()
{
	ROOT="${1}"
	[ ! -e "${ROOT}" ] || ! $(get_fstype "${ROOT}" >/dev/null) || ! /sbin/udevadm settle
}

# Parameter: Where to mount the filesystem
mountroot ()
{
	[ "$quiet" != "y" ] && log_begin_msg "Running /scripts/local-top"
	run_scripts /scripts/local-top
	[ "$quiet" != "y" ] && log_end_msg

	# If the root device hasn't shown up yet, give it a little while
	# to deal with removable devices
	while root_missing "${ROOT}"; do
		log_begin_msg "Waiting for root file system..."

		# Default delay is 30s
		if [ -z "${ROOTDELAY}" ]; then
			slumber=30
		else
			slumber=${ROOTDELAY}
		fi
		if [ -x /sbin/usplash_write ]; then
			/sbin/usplash_write "TIMEOUT ${slumber}" || true
		fi

		slumber=$(( ${slumber} * 10 ))
		while root_missing "${ROOT}"; do
			/bin/sleep 0.1
			slumber=$(( ${slumber} - 1 ))
			[ ${slumber} -gt 0 ] || break
		done

		if [ ${slumber} -gt 0 ]; then
			log_end_msg 0
		else
			log_end_msg 1 || true
		fi
		if [ -x /sbin/usplash_write ]; then
			/sbin/usplash_write "TIMEOUT 15" || true
		fi

		# Run failure hooks, hoping one of them can fix up the system
		# and we can restart the wait loop.  If they all fail, abort
		# and move on to the panic handler and shell.
		if root_missing "${ROOT}" && ! try_failure_hooks; then
			break
		fi
	done

	# We've given up, but we'll let the user fix matters if they can
	while root_missing "${ROOT}"; do
		# give hint about renamed root
		case "${ROOT}" in 
		/dev/hd*)
			suffix="${ROOT#/dev/hd}"
			major="${suffix%[[:digit:]]}"
			major="${major%[[:digit:]]}"
			if [ -d "/sys/block/sd${major}" ]; then
				echo "WARNING bootdevice may be renamed. Try root=/dev/sd${suffix}"
			fi
			;;
		/dev/sd*)
			suffix="${ROOT#/dev/sd}"
			major="${suffix%[[:digit:]]}"
			major="${major%[[:digit:]]}"
			if [ -d "/sys/block/hd${major}" ]; then
				echo "WARNING bootdevice may be renamed. Try root=/dev/hd${suffix}"
			fi
			;;
		esac
		echo "Gave up waiting for root device.  Common problems:"
		echo " - Boot args (cat /proc/cmdline)"
		echo "   - Check rootdelay= (did the system wait long enough?)"
		echo "   - Check root= (did the system wait for the right device?)"
		echo " - Missing modules (cat /proc/modules; ls /dev)"
		panic "ALERT!  ${ROOT} does not exist.  Dropping to a shell!"
	done

	# Get the root filesystem type if not set
	if [ -z "${ROOTFSTYPE}" ]; then
		FSTYPE=$(get_fstype "${ROOT}")
	else
		FSTYPE=${ROOTFSTYPE}
	fi

	[ "$quiet" != "y" ] && log_begin_msg "Running /scripts/local-premount"
	run_scripts /scripts/local-premount
	[ "$quiet" != "y" ] && log_end_msg

	if [ ${readonly} = y ] && \
	   [ -z "$LOOP" ]; then
		roflag=-r
	else
		roflag=-w
	fi

	# FIXME This has no error checking
	modprobe ${FSTYPE}

	# FIXME This has no error checking
	# Mount root
	mount ${roflag} -t ${FSTYPE} ${ROOTFLAGS} ${ROOT} ${rootmnt}
	mountroot_status="$?"
	if [ "$LOOP" ]; then
		if [ "$mountroot_status" != 0 ]; then
			if [ ${FSTYPE} = ntfs ] || [ ${FSTYPE} = vfat ]; then
				panic "
Could not mount the partition ${ROOT}.
This could also happen if the file system is not clean because of an operating
system crash, an interrupted boot process, an improper shutdown, or unplugging
of a removable device without first unmounting or ejecting it.  To fix this,
simply reboot into Windows, let it fully start, log in, run 'chkdsk /r', then
gracefully shut down and reboot back into Windows. After this you should be
able to reboot again and resume the installation.
(filesystem = ${FSTYPE}, error code = $mountroot_status)
"
			fi
		fi
	
		mkdir -p /host
		mount -o move ${rootmnt} /host

		while [ ! -e "/host/${LOOP#/}" ]; do
			panic "ALERT!  /host/${LOOP#/} does not exist.  Dropping to a shell!"
		done

		# Get the loop filesystem type if not set
		if [ -z "${LOOPFSTYPE}" ]; then
			eval $(fstype < "/host/${LOOP#/}")
		else
			FSTYPE="${LOOPFSTYPE}"
		fi
		if [ "$FSTYPE" = "unknown" ] && [ -x /lib/udev/vol_id ]; then
			FSTYPE=$(/lib/udev/vol_id -t "/host/${LOOP#/}")
			[ -z "$FSTYPE" ] && FSTYPE="unknown"
		fi

		if [ ${readonly} = y ]; then
			roflag=-r
		else
			roflag=-w
		fi

		# FIXME This has no error checking
		modprobe loop
		modprobe ${FSTYPE}

		# FIXME This has no error checking
		mount ${roflag} -o loop -t ${FSTYPE} ${LOOPFLAGS} "/host/${LOOP#/}" ${rootmnt}

		if [ -d ${rootmnt}/host ]; then
			mount -o move /host ${rootmnt}/host
		fi
	fi

	[ "$quiet" != "y" ] && log_begin_msg "Running /scripts/local-bottom"
	run_scripts /scripts/local-bottom
	[ "$quiet" != "y" ] && log_end_msg
}
EOF

# change the owner and permission.
chmod 644 $INITRD_DIR/scripts/local;
chown 0:0 $INITRD_DIR/scripts/local;

