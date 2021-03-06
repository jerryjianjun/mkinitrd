#!/bin/sh
#
# Description	: framebuffer
# Authors	: jianjun jiang - jjjstudio@gmail.com
# Version	: 0.01
# Path		: /scripts/init-top/framebuffer
# Notes		: 


# echo the title.
echo "[init-top] Create /scripts/init-top/framebuffer ...";

# The contents of /scripts/init-top/framebuffer file.
cat > $INITRD_DIR/scripts/init-top/framebuffer << "EOF"
#!/bin/sh

PREREQ=""
prereqs()
{
	echo "$PREREQ"
}
case $1 in
# get pre-requisites
prereqs)
	prereqs
	exit 0
	;;
esac


# The options part of the kernel "video=" argument (i.e. everyting
# after "video=<fbdriver>:") has very inconsistent rules.
#
# Generally the following applies:
# 1) options are comma-separated
# 2) options can be in either of these three forms:
#    <arg>=<value>, <arg>:<value>, <boolean-arg>.
# 3) the "mode" option has the form <xres>x<yres>[M][R][-<bpp>][@<refresh>][i][m]
#    and may or may not start with "mode="
#
# When the options are used with modules, they need to be space-separated
# and the following conversions are needed:
#	<arg>:<value> -> <arg>=<value>
#	<boolean-arg> -> <boolean-arg>=1
#	<modevalue>   -> mode=<modevalue>
parse_video_opts()
{
	local OPTS="$1"
	local IFS=","

	# Must be a line like video=<fbdriver>:<opt1>,[opt2]...
	if [ "${OPTS}" = "${OPTS%%:*}" ]; then
		return
	fi
	OPTS="${OPTS#*:}"
	for opt in ${OPTS}; do
		# Already in the "<arg>=<value>" form
		if [ "${opt}" != "${opt#*=}" ]; then
			echo -n "$opt "
		# In the "<arg>:<value>" form
		elif [ "${opt}" != "${opt#*:}" ]; then
			echo -n "${opt%:*}=${opt#*:} "
		# Presumably a modevalue without the "mode=" prefix
		elif [ "${opt}" != "${opt#[0-9]*x[0-9]}" ]; then
			echo -n "mode=$opt "
		# Presumably a boolean
		else
			echo -n "${opt}=1 "
		fi
	done
}

FB=""
OPTS=""

for x in $(cat /proc/cmdline); do
	case ${x} in
	vga=*)
		FB="vesafb";
		OPTS="";
		;;
	video=*)
		FB=${x#*=}
		FB="${FB%%:*}"
		OPTS="$(parse_video_opts "${x}")"
	esac
done

# Map command line name to module name
case ${FB} in
matroxfb)
	FB=matroxfb_base
	;;
*)
	;;
esac

if [ -n "${FB}" ]; then
	unset MODPROBE_OPTIONS
	modprobe -Q fbcon
	modprobe -Q ${FB} ${OPTS}
fi

if [ -e /proc/fb ]; then
	while read fbno desc; do
		if [ $(($fbno < 32)) ]; then
			mknod /dev/fb${fbno} c 29 ${fbno}
		fi
	done < /proc/fb
else
	mknod /dev/fb0 c 29 0
fi
EOF

# change the owner and permission.
chmod 755 $INITRD_DIR/scripts/init-top/framebuffer;
chown 0:0 $INITRD_DIR/scripts/init-top/framebuffer;

