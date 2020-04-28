#!/bin/sh

# Schedule a filesystem scan every hour unless one is in progress.
echo "$(($RANDOM % 60))   *   *   *   *   /scan.sh > /proc/1/fd/1 2>&1" >> /var/spool/cron/crontabs/root

# Bootstrap the database if clamav is running for the first time
[ -f /data/main.cvd ] || freshclam

# Run the update daemon
freshclam -d

# Run cron
crond

# Run clamav
clamd
