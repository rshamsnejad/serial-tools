#!/bin/bash

################################################################################
# OPTION PARSING
################################################################################

### BEGIN GETOPT

OPTS=`getopt -o hblc --long help,block,line,character: -n 'parse-options' -- "$@"`

if [ $? != 0 ] ; then echo "Failed parsing options." >&2 ; exit 1 ; fi

# echo "$OPTS"
eval set -- "$OPTS"

HELP=false
BLOCK=false
LINE=false
CHARACTER=false

while true; do
	case "$1" in
		-h | --help )		HELP=true; shift ;;
		-b | --block )		BLOCK=true; shift ;;
		-l | --line )		LINE=true; shift ;;
		-c | --character )	CHARACTER=true; shift ;;
		-- ) shift; break ;;
		* ) break ;;
  	esac
done

# echo HELP=$HELP
# echo BLOCK=$BLOCK
# echo LINE=$LINE
# echo CHARACTER=$CHARACTER

### END GETOPT

### BEGIN SANITY CHECK

USAGE=$(cat << EOF
Usage : $0 [-hblc] <serial device>
Example : $0 -l /dev/ttyUSB0

-h, --help : 	  Show this message

-b, --block : 	  Block mode. In this mode you can freely type,
		  and all will be sent to the device after the
		  following character sequence (which is not sent
		  itself) :
			  EOT<Enter>

-l, --line :	  Line mode. In this mode everything is sent
		  upon pressing <Enter> (which is not sent itself).
		  This is much like a terminal behavior.

-c, --character : Character mode. In this mode, each single entered
		  character is sent straight away on key press.
EOF
)

DEVICE=$1

if [ ! $DEVICE ] || [ $# != 1 ] ; then
	echo >&2 "$USAGE"
	exit 1
elif ! [[ "$DEVICE" =~ ^\/dev\/tty[a-zA-Z0-9]{1,6}$ ]] ; then
	echo >&2 "ERROR : Incorrect device $DEVICE."
	exit 1
elif ! [ -c "$DEVICE" ] ; then
	cat >&2 <<- EOT
		ERROR : Device $DEVICE does not exist or is not
		a valid character file. Please check the path.
	EOT
	exit 1
elif ! [ -w "$DEVICE" ] ; then
	cat >&2 <<- EOT
		ERROR : Device $DEVICE is not writable by the
		current user. Please check the file's permissions.
	EOT
	exit 1
fi

if ( $BLOCK && $LINE ) || \
( $BLOCK && $CHARACTER ) || \
( $LINE && $CHARACTER ) || \
( ! ( $BLOCK || $LINE || $CHARACTER ) )
then
	echo >&2 "ERROR : Please choose a single mode of operation."
	echo
	echo >&2 "$USAGE"
	exit 1
fi

### END SANITY CHECK

################################################################################
# BEGINNING OF ACTUAL PROGRAM
################################################################################



cat << EOT
============== Serial port output ===============
Everything typed here will be sent as is to the
serial device after each press of <Enter> (which
will not be sent itself)
Type <Ctrl+C> to exit.

EOT

USERINPUT=""

while true ; do

	if ! [ -c $DEVICE -a -w $DEVICE ] ; then
		echo >&2 "ERROR : Lost access to device $DEVICE. Aborting."
		exit 1
	fi

	read -p "$DEVICE> " USERINPUT
	echo "$USERINPUT" > $DEVICE
done
