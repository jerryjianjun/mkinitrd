#!/bin/sh
#
# Description	: 95-udev-late.rules
# Authors	: jianjun jiang - jjjstudio@gmail.com
# Version	: 0.01
# Path		: /etc/udev/rules.d/95-udev-late.rules
# Notes		: 


# echo the title.
echo "[udev] Create /etc/udev/rules.d/95-udev-late.rules ...";

# The contents of /etc/udev/rules.d/95-udev-late.rules file.
cat > $INITRD_DIR/etc/udev/rules.d/95-udev-late.rules << "EOF"
# do not edit this file, it will be overwritten on update

# run a command on remove events
ACTION=="remove", ENV{REMOVE_CMD}!="", RUN+="$env{REMOVE_CMD}"

# event to be catched by udevmonitor
RUN+="socket:@/org/kernel/udev/monitor"
EOF

# change the owner and permission.
chmod 644 $INITRD_DIR/etc/udev/rules.d/95-udev-late.rules;
chown 0:0 $INITRD_DIR/etc/udev/rules.d/95-udev-late.rules;

