#!/bin/sh
#
# Description	: 20-names.rules
# Authors	: jianjun jiang - jjjstudio@gmail.com
# Version	: 0.01
# Path		: /etc/udev/rules.d/20-names.rules
# Notes		: 


# echo the title.
echo "[udev] Create /etc/udev/rules.d/20-names.rules ...";

# The contents of /etc/udev/rules.d/20-names.rules file.
cat > $INITRD_DIR/etc/udev/rules.d/20-names.rules << "EOF"
# This file establishes the device names according to Ubuntu policy.
# See udev(7) for syntax.
#
# Permissions and ownership of devices must not be set here, but in
# 40-permissions.rules; user-friendly symlinks to devices should be
# set in 60-symlinks.rules.

# CPU devices, group under /dev/cpu
KERNEL=="cpu[0-9]*",			NAME="cpu/%n/cpuid"
KERNEL=="msr[0-9]*",			NAME="cpu/%n/msr"
KERNEL=="microcode",			NAME="cpu/microcode"

# Device mapper targets
KERNEL=="device-mapper",		NAME="mapper/control"

# IEEE1394 devices, group under their own directories
KERNEL=="dv1394-[0-9]*",		NAME="dv1394/%n"
KERNEL=="video1394-[0-9]*",		NAME="video1394/%n"

# Infiniband devices
KERNEL=="umad[0-9]*",			NAME="infiniband/%k"
KERNEL=="issm[0-9]*",			NAME="infiniband/%k"
KERNEL=="uverbs[0-9]*",			NAME="infiniband/%k"
KERNEL=="ucm[0-9]*",			NAME="infiniband/%k"
KERNEL=="rdma_cm",			NAME="infiniband/%k"

# Input devices, group under /dev/input
KERNEL=="event[0-9]*",			NAME="input/%k"
KERNEL=="mice",				NAME="input/%k"
KERNEL=="mouse[0-9]*",			NAME="input/%k"
KERNEL=="js[0-9]*",			NAME="input/%k"
KERNEL=="ts[0-9]*",			NAME="input/%k"
KERNEL=="uinput",			NAME="input/%k"

# ISDN devices, group under /dev/capi
KERNEL=="capi",				NAME="capi20"
KERNEL=="capi[0-9]*",			NAME="capi/%n"

# Packet CD devices, group under /dev/pktcdvd
KERNEL=="pktcdvd",			NAME="pktcdvd/control"
KERNEL=="pktcdvd[0-9]*",		NAME="pktcdvd/%k"

# Sound devices, group under /dev/snd
KERNEL=="controlC[0-9]*",		NAME="snd/%k"
KERNEL=="hwC[D0-9]*",			NAME="snd/%k"
KERNEL=="midiC[D0-9]*",			NAME="snd/%k"
KERNEL=="pcmC[D0-9cp]*",		NAME="snd/%k"
KERNEL=="seq",				NAME="snd/%k"
KERNEL=="timer",			NAME="snd/%k"

# USB devices (usbfs replacement), group under /dev/bus/usb
SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", \
	NAME="bus/usb/$env{BUSNUM}/$env{DEVNUM}"

# Legacy usb_device class equivalent to above
SUBSYSTEM!="usb_device", GOTO="usb_device_end"
IMPORT{program}="usb_device_name --export %k"
ENV{USB_BUS}=="?*", ENV{USB_DEV}=="?*",	\
	NAME="bus/usb/$env{USB_BUS}/$env{USB_DEV}"
LABEL="usb_device_end"

# Other USB devices, commonly grouped under /dev/usb
KERNEL=="auer[0-9]*",			NAME="usb/%k"
KERNEL=="cpad[0-9]*",			NAME="usb/%k"
KERNEL=="dabusb[0-9]*",			NAME="usb/%k"
KERNEL=="hiddev[0-9]*",			NAME="usb/%k"
KERNEL=="legousbtower[0-9]*",		NAME="usb/%k"
SUBSYSTEMS=="usb", KERNEL=="lp[0-9]*",	NAME="usb/%k"

# Video devices, group dvb devices under /dev/dvb
SUBSYSTEM!="dvb", GOTO="dvb_end"
IMPORT{program}="dvb_device_name --export %k"
ENV{DVB_ADAPTER}=="?*", ENV{DVB_DEV}=="?*", \
	NAME="dvb/adapter$env{DVB_ADAPTER}/$env{DVB_NAME}"
LABEL="dvb_end"

# Video devices, group cards under /dev/dri
KERNEL=="card[0-9]*",			NAME="dri/%k"

# Zaptel devices, group under /dev/zap
KERNEL=="zapctl",			NAME="zap/ctl"
KERNEL=="zaptimer",			NAME="zap/timer"
KERNEL=="zapchannel",			NAME="zap/channel"
KERNEL=="zappseudo",			NAME="zap/pseudo"
KERNEL=="zap[0-9]*",			NAME="zap/%n"

# SCSI CD-ROM devices use /dev/scdN now
SUBSYSTEMS=="scsi", KERNEL=="sr[0-9]*",	NAME="scd%n"

# Raw block devices need to be /dev/raw/*
SUBSYSTEM=="raw", KERNEL=="raw[0-9]*",	NAME="raw/%k"

# Other devices
KERNEL=="hw_random",			NAME="hwrng"
KERNEL=="tun",				NAME="net/%k"
EOF

# change the owner and permission.
chmod 644 $INITRD_DIR/etc/udev/rules.d/20-names.rules;
chown 0:0 $INITRD_DIR/etc/udev/rules.d/20-names.rules;

