FROM debian:jessie
MAINTAINER Kai Hendry <hendry@webconverger.com>

RUN apt-get update || true
RUN apt-get install -y git live-build xorriso vim-tiny make isolinux

RUN git clone git://github.com/Webconverger/Debian-Live-config.git /root/Debian-Live-config

RUN ln -s /usr/lib/ISOLINUX/ /usr/share/

VOLUME /root/Debian-Live-config/webconverger/chroot

WORKDIR /root/Debian-Live-config/webconverger/

CMD /bin/bash

## Setup
# docker build -t webcbuildimage .
# docker run --name buildwebc -it -v $WEBC_CHECKOUT:/root/Debian-Live-config/webconverger/chroot webcbuildimage

# make # <--- run inside container

## Get the built ISO out

# docker cp buildwebc:/root/Debian-Live-config/webconverger/live-image-i386.hybrid.iso test.iso

##  When you need to revisit the image

# docker start -ai buildwebc
