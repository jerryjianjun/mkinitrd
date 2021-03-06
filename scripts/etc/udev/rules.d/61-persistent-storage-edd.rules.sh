#!/bin/sh
#
# Description	: 61-persistent-storage-edd.rules
# Authors	: jianjun jiang - jjjstudio@gmail.com
# Version	: 0.01
# Path		: /etc/udev/rules.d/61-persistent-storage-edd.rules
# Notes		: 


# echo the title.
echo "[udev] Create /etc/udev/rules.d/61-persistent-storage-edd.rules ...";

# The contents of /etc/udev/rules.d/61-persistent-storage-edd.rules file.
cat > $INITRD_DIR/etc/udev/rules.d/61-persistent-storage-edd.rules << "EOF"
# do not edit this file, it will be overwritten on update

ACTION!="add", GOTO="persistent_storage_edd_end"
SUBSYSTEM!="block", GOTO="persistent_storage_edd_end"
KERNEL!="sd*|hd*", GOTO="persistent_storage_edd_end"

# BIOS Enhanced Disk Device
ENV{DEVTYPE}=="disk", IMPORT{program}="edd_id --export $tempnode"
ENV{DEVTYPE}=="disk", ENV{ID_EDD}=="?*", SYMLINK+="disk/by-id/edd-$env{ID_EDD}"
ENV{DEVTYPE}=="partition", ENV{ID_EDD}=="?*", SYMLINK+="disk/by-id/edd-$env{ID_EDD}-part%n"

LABEL="persistent_storage_edd_end"
EOF

# change the owner and permission.
chmod 644 $INITRD_DIR/etc/udev/rules.d/61-persistent-storage-edd.rules;
chown 0:0 $INITRD_DIR/etc/udev/rules.d/61-persistent-storage-edd.rules;

