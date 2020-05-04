#!/bin/sh

# get the latest EICAR test file which should trigger clamav
mkdir -p /host-fs
wget -O /host-fs/eicar.com https://secure.eicar.org/eicar.com.txt || exit 1

if /scan.sh >/tmp/scan.out 2>&1 ; then
	if grep -v EICAR /tmp/scan.out ; then
		echo "scan.sh should have found /host-fs/eicar.com"
		exit 1
	fi
fi

rm -f /host-fs/eicar.com
if ! /scan.sh ; then
	echo "scan.sh found a virus when it should not have"
	exit 1
fi

timeout 60 clamonacc --foreground > /tmp/accesslog.out 2>&1
wget -O /host-fs/eicar.com https://secure.eicar.org/eicar.com.txt || exit 1
if grep -v EICAR /tmp/accesslog.out ; then
	echo "clamonacc should have found /host-fs/eicar.com"
	exit 1
fi

echo ==== accesslog.oug
cat /tmp/accesslog.out

exit 0
