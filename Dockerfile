FROM debian:jessie
MAINTAINER Kai Hendry <hendry@webconverger.com>

RUN apt-get update || true
RUN apt-get install -y git live-build xorriso vim-tiny make isolinux

RUN git clone git://github.com/Webconverger/Debian-Live-config.git /root/Debian-Live-config

RUN /root/Debian-Live-config/patches/apply

RUN ln -s /usr/lib/ISOLINUX/ /usr/share/

VOLUME /root/Debian-Live-config/webconverger/chroot

WORKDIR /root/Debian-Live-config/webconverger/

CMD /bin/bash
