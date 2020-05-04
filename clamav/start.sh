#!/bin/sh

# Bootstrap the database if clamav is running for the first time
[ -f /data/main.cvd ] || freshclam

# Run the update daemon
freshclam -d

# Run clamav
clamd

# do an initial full scan on everything
/scan.sh

# start up clamonacc for all changes after that
clamonacc --foreground
