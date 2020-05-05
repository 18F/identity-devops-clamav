#!/bin/sh
# Perform a scan

echo "$(date)" Starting scan.sh
clamdscan \
  --multiscan \
  --fdpass \
  --verbose \
  --stdout \
  /host-fs
