#!/bin/sh

# get the latest EICAR test file
wget https://secure.eicar.org/eicar.com.txt || exit 1

# scan should result in a hit
if clamscan eicar.com.txt ; then
	echo did not find EICAR:  something is broken
	exit 1
fi

# scan should not result in a hit
if clamscan /scan.sh ; then
	echo /scan.sh is clean:  good
fi

exit 0
