#!/bin/bash

################################################################################
# DEBUG HELPER
################################################################################

# Set this to true if you want to output debug messages
# and activate the following tools
_DEBUG=true
# Set this to false if you want to disable debug output
# but not the rest of the following
_VERBOSE=true


if ( ! $_DEBUG ) ; then
	_VERBOSE=false
fi

_DEBUG_PRINT()
{
	if ( $_VERBOSE ) ; then
		echo "-- DEBUG : $*"
	fi
}

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
	else
		_DEBUG_PRINT "Skipped instruction line ${BASH_LINENO[0]}"
	fi
}

_ERROR_PRINT()
{
	echo >&2 "$*"
}

################################################################################
# BEGINNING OF ACTUAL PROGRAM
################################################################################

# List all devices
SYS_LIST_GLOBAL=($(ls -d /sys/class/tty/*/device/driver | sed -e 's/\/device\/driver//g'))

for i in "${SYS_LIST_GLOBAL[@]}"
do
	_DEBUG_PRINT "GLOB $i"
done

# List only internal /dev/ttyS*
SYS_LIST_INTERNAL=()

for i in "${SYS_LIST_GLOBAL[@]}"
do
	if [ $i != "*/ttyS*" ] ; then
		SYS_LIST_INTERNAL+=("$i")
	fi
done

for i in "${SYS_LIST_INTERNAL[@]}"
do
	_DEBUG_PRINT "INT $i"
done

# Remove unused internal /dev/ttyS* devices
DELETE_ARRAY=()

for i in "${SYS_LIST_INTERNAL[@]}"
do
	if [ "x$(cat "$i/type")" = "x0" ] ; then
		DELETE_ARRAY+=("$i")
	fi
done

for i in "${DELETE_ARRAY[@]}"
do
	_DEBUG_PRINT "DELETE $i"
done

for i in "${DELETE_ARRAY[@]}"
do
	SYS_LIST_GLOBAL=("${SYS_LIST_GLOBAL[@]/$i/}")
done


# Resulting list
for i in "${SYS_LIST_GLOBAL[@]}"
do
	_DEBUG_PRINT "SYS $i"
done

# for i in $(echo "$SYS_LIST_GLOBAL" | grep "ttyS")
# do
# 	if [ "x$(cat $i)" = "0" ] ; then
#
# DEVICE_LIST=$(\
# 	for i in $SYS_LIST_GLOBAL
# 	do
# 		echo -n "/dev/"
# 		udevadm info -q name -p $i
# 	done \
# 	)
#
# _DEBUG_PRINT "$DEVICE_LIST"
