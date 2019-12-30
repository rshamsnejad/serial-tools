#!/bin/bash

################################################################################
# OPTION PARSING
################################################################################

USAGE=$(cat <<- EOT
	Usage : $0 <serial device>
	Example : $0 /dev/ttyUSB0
EOT
)
DEVICE=$1

if [ ! $DEVICE ] || [ $# != 1 ] ; then
	echo "$USAGE"
	exit 1
elif ! [[ "$DEVICE" =~ ^\/dev\/tty[a-zA-Z0-9]{1,6}$ ]] ; then
	echo "Incorrect device $DEVICE."
	exit 1
elif ! [ -c "$DEVICE" ] ; then
	cat <<- EOT
		Device $DEVICE does not exist or is not a valid
		character file. Please check the path.
	EOT
	exit 1
elif ! [ -w "$DEVICE" ] ; then
	cat <<- EOT
		Device $DEVICE is not writable by the current user.
		Please check the file's permissions.
	EOT
	exit 1
fi

################################################################################
# BEGINNING OF ACTUAL PROGRAM
################################################################################

cat << EOT
============== Serial port output ===============
Everything typed here will be sent as is to the
serial device after each press of <Enter>.
Type <Ctrl+C> to exit.
EOT
