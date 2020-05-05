# ClamAV!

This repo contains the code that creates a secops-clamav image.
It does an initial scan of everything, then uses inotifywait to
identify newly created and files that were updated and scans them.
We have excluded a few common files that make a lot of noise and
are known to be good, like elasticsearch indexes and /proc and
so on.

