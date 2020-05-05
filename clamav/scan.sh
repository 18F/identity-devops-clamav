#!/bin/sh
# Perform a scan

echo "$(date)" Starting scan.sh
for i in $* ; do
  clamdscan \
    --multiscan \
    --fdpass \
    --verbose \
    --stdout \
    "$i"
done
