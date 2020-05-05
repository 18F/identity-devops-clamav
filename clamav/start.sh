#!/bin/sh

# Bootstrap the database if clamav is running for the first time
[ -f /data/main.cvd ] || freshclam

# Run the update daemon
freshclam -d

# Run clamd for clamonacc to use
clamd &
sleep 50

# do an initial full scan on everything
/scan.sh

# start up inotifywait and scan files that are created or updated
sysctl fs.inotify.max_user_watches=524288
inotifywait -r -m --exclude '\/host-fs\/dev\/|\/host-fs\/proc\/|\/host-fs\/sys\/|\/index\/_|translog\/translog.ckp|\/host-fs\/run\/containerd\/io.containerd.runtime.v1.linux/moby.*\.pid$|\/host-fs\/run\/docker\/.*-stdout$|\/host
-fs\/run\/docker\/.*-stderr|\/host-fs\/run\/containerd\/io.containerd.runtime.v1.linux\/moby\/.*\/log.json$|/host-fs/run/docker/runtime-runc/moby\/.*runc\.[a-zA-Z0-9]*$' -e close_write -e create --format %w%f /host-fs | while read line ; do
	clamdscan --fdpass --verbose --stdout "$line"
done
