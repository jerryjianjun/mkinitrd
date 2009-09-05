#!/bin/sh
#
# Description	: 90-modprobe.rules
# Authors	: jianjun jiang - jjjstudio@gmail.com
# Version	: 0.01
# Path		: /etc/udev/rules.d/90-modprobe.rules
# Notes		: 


# echo the title.
echo "[udev] Create /etc/udev/rules.d/90-modprobe.rules ...";

# The contents of /etc/udev/rules.d/90-modprobe.rules file.
cat > $INITRD_DIR/etc/udev/rules.d/90-modprobe.rules << "EOF"
# This file causes modules to be loaded for inserted devices.
# See udev(7) for syntax.
#
# This file should only specify rules that cause modprobe to be called,
# programs that configure or activate hardware should be called in
# 80-programs.rules

ACTION!="add", GOTO="modprobe_end"

# Load IDE class modules based on the media type
SUBSYSTEM!="ide", GOTO="ide_end"
IMPORT{program}="ide_media --export $devpath"
ENV{IDE_MEDIA}=="cdrom",		RUN+="/sbin/modprobe -Qba ide-cd"
ENV{IDE_MEDIA}=="disk",			RUN+="/sbin/modprobe -Qba ide-disk"
ENV{IDE_MEDIA}=="floppy",		RUN+="/sbin/modprobe -Qba ide-floppy"
ENV{IDE_MEDIA}=="tape",			RUN+="/sbin/modprobe -Qba ide-tape"
LABEL="ide_end"

# Load i2o class modules unequivocably until we know more about them
SUBSYSTEM=="i2o",			RUN+="/sbin/modprobe -Qba i2o-block"

# Load MMC class modules unequivocably until we know more about them
SUBSYSTEM=="mmc",			RUN+="/sbin/modprobe -Qba mmc-block"

# Load SCSI class modules based on the device class
SUBSYSTEM!="scsi", GOTO="scsi_end"
ATTR{type}=="0|7|14",   		RUN+="/sbin/modprobe -Qba sd_mod"
ATTR{type}=="1", ATTRS{vendor}=="Onstream", ATTRS{model}!="ADR*", \
		        		RUN+="/sbin/modprobe -Qba osst"
ATTR{type}=="1", ATTRS{vendor}=="Onstream", ATTRS{model}=="ADR*", \
		        		RUN+="/sbin/modprobe -Qba st"
ATTR{type}=="1", ATTRS{vendor}=="Onstream", ATTRS{model}=="ADR*", \
		        		RUN+="/sbin/modprobe -Qba st"
ATTR{type}=="[345]",    		RUN+="/sbin/modprobe -Qba sr_mod"
ATTR{type}=="8",	    		RUN+="/sbin/modprobe -Qba ch"
RUN+="/sbin/modprobe -Qba sg"
LABEL="scsi_end"

# Load VIO modules based on the device type
# (modules that lack modalias support)
SUBSYSTEM!="vio", GOTO="vio_end"
IMPORT{program}="vio_type --export $devpath"
ENV{VIO_TYPE}=="serial",		RUN+="/sbin/modprobe -Qba hvc_console"
ENV{VIO_TYPE}=="serial-server",		RUN+="/sbin/modprobe -Qba hvcs"
ENV{VIO_TYPE}=="network",		RUN+="/sbin/modprobe -Qba ibmveth"
ENV{VIO_TYPE}=="vscsi",			RUN+="/sbin/modprobe -Qba ibmvscsic"
ENV{VIO_TYPE}=="vlan",			RUN+="/sbin/modprobe -Qba iseries_veth"
ENV{VIO_TYPE}=="viodasd",		RUN+="/sbin/modprobe -Qba viodasd"
ENV{VIO_TYPE}=="viocd",			RUN+="/sbin/modprobe -Qba viocd"
ENV{VIO_TYPE}=="vnet",			RUN+="/sbin/modprobe -Qba sunvnet"
ENV{VIO_TYPE}=="vdisk",			RUN+="/sbin/modprobe -Qba sunvdc"
LABEL="vio_end"

# Hack to load ti flashmedia subsystem drivers
SUBSYSTEM!="tifm", GOTO="tifm_end"
ENV{TIFM_CARD_TYPE}=="SD",		RUN+="/sbin/modprobe -Qba tifm_sd"
ENV{TIFM_CARD_TYPE}=="MS",		RUN+="/sbin/modprobe -Qba tifm_ms"
LABEL="tifm_end"

# Not sure how to tell if it's MS or MSPro yet...
SUBSYSTEM!="memstick", GOTO="memstick_end"
RUN+="/sbin/modprobe -Qba ms_block"
RUN+="/sbin/modprobe -Qba mspro_block"
LABEL="memstick_end"

# Load drivers that match kernel-supplied alias
ENV{MODALIAS}=="?*",			RUN+="/sbin/modprobe -Q $env{MODALIAS}"

LABEL="modprobe_end"
EOF

# change the owner and permission.
chmod 644 $INITRD_DIR/etc/udev/rules.d/90-modprobe.rules;
chown 0:0 $INITRD_DIR/etc/udev/rules.d/90-modprobe.rules;

