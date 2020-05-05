#!/bin/sh

# Bootstrap the database if clamav is running for the first time
[ -f /data/main.cvd ] || freshclam

# Run the update daemon
freshclam -d

# Run clamd for clamdscan to use and wait until it's ready
clamd >/dev/null &
until clamdscan --no-summary --fdpass --stdout --infected /etc/passwd >/dev/null 2>&1 ; do
	sleep 2
done

# do an initial full scan on everything
/scan.sh

# start up inotifywait and scan files that are created
# Filter out stuff that is noisy and known to be normal activity.
sysctl fs.inotify.max_user_watches=524288
inotifywait -e close_write -e create --format %w%f -r -m --exclude '\/host-fs\/dev\/|\/host-fs\/proc\/|\/host-fs\/sys\/|\/index\/_|translog\/translog.ckp|\/host-fs\/run\/containerd\/io.containerd.runtime.v1.linux/moby.*\.pid$|\/host-fs\/run\/docker\/.*-stdout$|\/host
-fs\/run\/docker\/.*-stderr|\/host-fs\/run\/containerd\/io.containerd.runtime.v1.linux\/moby\/.*\/log.json$|/host-fs/run/docker/runtime-runc/moby\/.*runc\.[a-zA-Z0-9]*$|\/host-fs\/var\/lib\/docker\/overlay2\/[a-z0-9]*\/merged\/sys\/' /host-fs | while read line ; do
	clamdscan --no-summary --fdpass --stdout --infected "$line"
done
