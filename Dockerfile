# this is based heavily off here: https://github.com/GoogleCloudPlatform/community/blob/master/tutorials/gcp-cos-clamav/Dockerfile
FROM alpine:3

ENV CLAM_VERSION=0.102.1-r0

COPY clamav /

# python3 shared with most images
RUN apk add --no-cache rsyslog wget clamav=$CLAM_VERSION clamav-libunrar=$CLAM_VERSION inotify-tools && \
    mv /conf/* /etc/clamav/ && \
    mkdir -p /logs /data /host-fs && \
    echo `date`: File created >> /logs/clamscan.log && \
    chown -R clamav /logs && \
    chmod +rw /var/lib/clamav* && \
    chmod +x /health.sh /scan.sh /start.sh

RUN freshclam

CMD /start.sh
