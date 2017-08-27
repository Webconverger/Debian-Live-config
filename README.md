# Webconverger [Debian Live](http://live.debian.net) build configuration

For the source of the rootfs aka `$WEBC_CHECKOUT`, please use: <https://github.com/Webconverger/webc>

# Setup

	yourhost # docker run --name buildwebc -it -v $WEBC_CHECKOUT:/root/Debian-Live-config/webconverger/chroot webc/isobuilder

# Building the image

	insidecontainer # make # <--- run inside container

# Get the built ISO out

	yourhost # docker cp buildwebc:/root/Debian-Live-config/webconverger/live-image-i386.hybrid.iso test.iso

	or see [build.sh](build.sh).

##  When you need to revisit the image

	yourhost # docker start -ai buildwebc

or

	yourhost # docker start buildwebc
	yourhost # docker exec -it buildwebc /bin/bash
