#!/bin/sh

# get things running and wait until they are going
/start.sh > /tmp/accesslog.out 2>&1 &
echo "sleeping until clamav is ready for testing"
until clamdscan --no-summary --fdpass --stdout --infected /etc/passwd >/dev/null 2>&1 ; do
	sleep 2
done

# get the latest EICAR test file which should get spotted in a scan
mkdir -p /host-fs
wget -O /host-fs/eicar.com https://secure.eicar.org/eicar.com.txt || exit 1

if /scan.sh >/tmp/scan.out 2>&1 ; then
	echo "scan.sh did not find any viruses, but should have found /host-fs/eicar.com"
	exit 1
else
	if ! grep EICAR /tmp/scan.out >/dev/null ; then
		echo "scan.sh should have found EICAR in /host-fs/eicar.com"
		exit 1
	fi
fi

# test to make sure that it doesn't get any false positives if there are no viruses
rm -f /host-fs/eicar.com
if ! /scan.sh >/dev/null 2>&1 ; then
	echo "scan.sh found a virus when it should not have"
	exit 1
fi

# check if inotify scan spotted EICAR
if ! grep EICAR /tmp/accesslog.out >/dev/null ; then
	echo "inotifywait should have found /host-fs/eicar.com"
	exit 1
fi

exit 0
