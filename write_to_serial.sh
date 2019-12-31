#!/bin/bash

################################################################################
# DEBUG HELPER
################################################################################

# Set this to true if you want to output debug messages
# and activate the following tools
_DEBUG=false
# Set this to false if you want to disable debug output
# but not the rest of the following
_VERBOSE=false


if ( ! $_DEBUG ) ; then
	_VERBOSE=false
fi

_DEBUG_RUN()
{
	if ( $_DEBUG ) ; then
		$@
	fi
}

_DEBUG_RUN_WITH_TRACE()
{
	if ( $_DEBUG ) ; then
		set -x
		$@
		set +x
	fi
}

_DEBUG_DONT_RUN()
{
	if ( ! $_DEBUG ) ; then
		$@
	fi
}

_DEBUG_PRINT()
{
	if ( $_VERBOSE ) ; then
		echo "-- DEBUG : $*"
	fi
}

_ERROR_PRINT()
{
	echo >&2 "$*"
}

################################################################################
# OPTION PARSING
################################################################################

### BEGIN GETOPT

OPTS=`getopt -o hblc --long help,block,line,character: -n 'parse-options' -- "$@"`

if [ $? != 0 ] ; then
	_ERROR_PRINT "ERROR : Failed parsing options."
	exit 1
fi

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

_DEBUG_PRINT "DEVICE=$1"
_DEBUG_PRINT "HELP=$HELP"
_DEBUG_PRINT "BLOCK=$BLOCK"
_DEBUG_PRINT "LINE=$LINE"
_DEBUG_PRINT "CHARACTER=$CHARACTER"

### END GETOPT

### BEGIN SANITY CHECK

USAGE=$(cat << EOT
Usage : $0 [-hblc] <serial device>
Example : $0 -l /dev/ttyUSB0

-h, --help : 	  Show this message

-b, --block : 	  Block mode. In this mode you can freely type,
		  and all will be sent to the device after pressing
		  <Ctrl-D> (which is not sent itself)

-l, --line :	  Line mode. In this mode everything is sent
		  upon pressing <Enter> (which is not sent itself).
		  This is much like a terminal behavior.

-c, --character : Character mode. In this mode, each single entered
		  character is sent straight away on key press.
EOT
)

DEVICE=$1

if [ ! $DEVICE ] || [ $# != 1 ] ; then
	_ERROR_PRINT "$USAGE"
	exit 1
elif ! [[ "$DEVICE" =~ ^\/dev\/tty[a-zA-Z0-9]{1,6}$ ]] ; then
	_ERROR_PRINT "ERROR : Incorrect device $DEVICE."
	_DEBUG_DONT_RUN exit 1
elif ! [ -c "$DEVICE" ] ; then
	cat >&2 <<- EOT
		ERROR : Device $DEVICE does not exist or is not
		a valid character file. Please check the path.
	EOT
	_DEBUG_DONT_RUN exit 1
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
	_ERROR_PRINT "ERROR : Please choose a single mode of operation."
	echo
	_ERROR_PRINT "$USAGE"
	exit 1
fi

### END SANITY CHECK

################################################################################
# BEGINNING OF ACTUAL PROGRAM
################################################################################

# Set the mode to work with
PROMPT_DEVICE='"$DEVICE> "'
READ_PROMPT="-p $PROMPT_DEVICE"
READ_VARIABLE="USERINPUT"
SEND_COMMAND="echo \"\$USERINPUT\" > \$DEVICE"

NOTICE="=== Mode : "
PROMPT_COMMAND=""

if ( $BLOCK ) ; then
	NOTICE+="BLOCK. the taskbar, Block the taskbar..."
	NOTICE+=$'\n'
	NOTICE+="Type <Ctrl-D> to send a block"
	PROMPT_COMMAND="echo -n $PROMPT_DEVICE ; $READ_VARIABLE="'$(cat) ; echo'
elif ( $LINE ) ; then
	NOTICE+="LINE. Hold it, love isn't always on time"
	PROMPT_COMMAND="read $READ_PROMPT $READ_VARIABLE"
elif ( $CHARACTER ) ; then
	NOTICE+="CHARACTER. Going through life one byte at a time"
	PROMPT_COMMAND="read $READ_PROMPT -N 1 $READ_VARIABLE ; echo"
else
	_ERROR_PRINT "ERROR : Unable to set mode. Aborting."
	exit 1
fi

_DEBUG_PRINT "PROMPT_DEVICE=$PROMPT_DEVICE"
_DEBUG_PRINT "READ_PROMPT=$READ_PROMPT"
_DEBUG_PRINT "READ_VARIABLE=$READ_VARIABLE"
_DEBUG_PRINT "SEND_COMMAND=$SEND_COMMAND"
_DEBUG_PRINT "NOTICE=$NOTICE"
_DEBUG_PRINT "PROMPT_COMMAND=$PROMPT_COMMAND"


echo "============== Serial port output ==============="
echo "$NOTICE"
echo "Type <Ctrl-C> to exit"

USERINPUT=""

while true ; do

	if ! [ -c $DEVICE -a -w $DEVICE ] ; then
		_ERROR_PRINT "ERROR : Lost access to device $DEVICE. Aborting."
		exit 1
	fi

	eval "$PROMPT_COMMAND"
	echo "$USERINPUT" > $DEVICE
done
