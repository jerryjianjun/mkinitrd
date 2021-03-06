#!/bin/sh
#
# Description	: create directory for /scripts.
# Authors	: jianjun jiang - jjjstudio@gmail.com
# Version	: 0.01
# Notes		: None
#


# echo the title.
echo "[scripts] Create directory for /scripts ...";

# source the common function.
source $PROG_DIR/common.sh;

# make sure the /scripts dirctory.
DIR=$INITRD_DIR/scripts/;
[ -d $DIR ] || { mkdir -p -m 0755 $DIR; chown 0:0 $DIR; }

# run all of scripts.
LoopScripts $PROG_DIR/scripts/scripts/ || { exit 1; }

# successed and exit.
exit 0;
