FROM busybox:1-musl

ADD --chmod=0755 start.sh /start.sh
ADD --chmod=0755 udhcpc.sh /usr/share/udhcpc/default.script

ENV INTERFACE=eth0

ENTRYPOINT [ "/start.sh" ]
