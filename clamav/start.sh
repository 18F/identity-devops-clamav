#!/bin/sh

# Bootstrap the database if clamav is running for the first time
[ -f /data/main.cvd ] || freshclam

# Run the update daemon
freshclam -d

# Run clamd for clamdscan to use and wait until it's ready
clamd >/dev/null 2>&1 &
until clamdscan --no-summary --fdpass --stdout --infected /etc/passwd >/dev/null 2>&1 ; do
	sleep 2
done

# do an initial full scan on everything
/scan.sh

# start up inotifywait and scan files that are created
# Filter out stuff that is noisy and known to be normal activity.
sysctl fs.inotify.max_user_watches=524288

# watch non-docker system
inotifywait -e close_write -e create --format %w%f -r -m --exclude '\/host-fs\/var\/lib\/docker\/|\/host-fs\/proc\/|\/host-fs\/sys\/|\/host-fs\/dev\/' /host-fs | while read line ; do
	clamdscan --no-summary --fdpass --stdout --infected "$line"
done

# watch docker containers filesystems.  Once an hour, restart so that we get new containers.
# exclude some stuff that we know is fine (just elasticsearch stuff for now)
watchem() {
	inotifywait -e close_write -e create --format %w%f -r -m --exclude '/host-fs/var/lib/kubelet/plugins/kubernetes.io/csi/pv/.*/globalmount/nodes' "$1" | while read line ; do
		clamdscan --no-summary --fdpass --stdout --infected "$line"
	done
}
while true ; do
	PIDS=""
	# watch docker filesystems
	for i in /host-fs/var/lib/docker/overlay2/*/merged ; do
		watchem "$i" &
		PIDS="$PIDS $!"
	done
	# watch persistent volumes
	for i in /host-fs/var/lib/kubelet/plugins/kubernetes.io/csi/pv/* ; do
		watchem "$i" &
		PIDS="$PIDS $!"
	done

	sleep 3600
	kill -9 $PIDS
done
