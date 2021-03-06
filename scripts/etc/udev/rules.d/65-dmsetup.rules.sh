#!/bin/sh
#
# Description	: 65-dmsetup.rules
# Authors	: jianjun jiang - jjjstudio@gmail.com
# Version	: 0.01
# Path		: /etc/udev/rules.d/05-options.rules
# Notes		: 


# echo the title.
echo "[udev] Create /etc/udev/rules.d/65-dmsetup.rules ...";

# The contents of /etc/udev/rules.d/65-dmsetup.rules file.
cat > $INITRD_DIR/etc/udev/rules.d/65-dmsetup.rules << "EOF"
SUBSYSTEM!="block",				GOTO="device_mapper_end"
KERNEL!="dm-*",					GOTO="device_mapper_end"
ACTION!="add|change",				GOTO="device_mapper_end"

# Obtain device status
IMPORT{program}="/sbin/dmsetup export -j%M -m%m"
ENV{DM_NAME}!="?*",				GOTO="device_mapper_end"

# these are temporary devices created by cryptsetup, we want to ignore them
# and also hide them from HAL
ENV{DM_NAME}=="temporary-cryptsetup-*",		OPTIONS="ignore_device"

# Make the device take the /dev/mapper name
OPTIONS+="string_escape=none", NAME="mapper/$env{DM_NAME}"
SYMLINK+="disk/by-id/dm-name-$env{DM_NAME}"
ENV{DM_UUID}=="?*", SYMLINK+="disk/by-id/dm-uuid-$env{DM_UUID}"

ENV{DM_STATE}=="SUSPENDED",			GOTO="device_mapper_end"
ENV{DM_TARGET_TYPES}=="|*error*",		GOTO="device_mapper_end"

# by-uuid and by-label symlinks
IMPORT{program}="vol_id --export $tempnode"

OPTIONS+="link_priority=-100"
ENV{DM_UUID}=="DMRAID-*", OPTIONS="link_priority=100"
ENV{DM_TARGET_TYPES}=="*snapshot-origin*", OPTIONS+="link_priority=-90"

ENV{ID_FS_UUID_ENC}=="?*",	ENV{ID_FS_USAGE}=="filesystem|other|crypto", \
	SYMLINK+="disk/by-uuid/$env{ID_FS_UUID_ENC}"
ENV{ID_FS_LABEL_ENC}=="?*",	ENV{ID_FS_USAGE}=="filesystem|other", \
	SYMLINK+="disk/by-label/$env{ID_FS_LABEL_ENC}"

LABEL="device_mapper_end"
EOF

# change the owner and permission.
chmod 644 $INITRD_DIR/etc/udev/rules.d/65-dmsetup.rules;
chown 0:0 $INITRD_DIR/etc/udev/rules.d/65-dmsetup.rules;

