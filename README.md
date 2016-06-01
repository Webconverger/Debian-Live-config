# Webconverger [Debian Live](http://live.debian.net) build configuration

For the source of the chroot aka `$WEBC_CHECKOUT`, please use: <https://github.com/Webconverger/webc>

# Setup

	# docker build -t webcbuildimage .
	# docker run --name buildwebc -it -v $WEBC_CHECKOUT:/root/Debian-Live-config/webconverger/chroot webcbuildimage

# Building the image

	# make # <--- run inside container

# Get the built ISO out

	# docker cp buildwebc:/root/Debian-Live-config/webconverger/live-image-i386.hybrid.iso test.iso

##  When you need to revisit the image

	# docker start -ai buildwebc
