#!/bin/sh
set -x
desc=$(git --git-dir $WEBC_CHECKOUT/.git/ describe)
docker run --name webc -v $WEBC_CHECKOUT:/root/Debian-Live-config/webconverger/chroot webc/isobuilder make
docker cp webc:/root/Debian-Live-config/webconverger/live-image-i386.hybrid.iso /tmp/$desc.iso || true
docker rm webc || true
if test -s /tmp/$desc.iso
then
        dir=$(date --rfc-3339=date)/$desc
        sha1=$(sha1sum /tmp/$desc.iso | cut -d' ' -f 1)
        mkdir -p $dir
        mv /tmp/$desc.iso $dir/$sha1.iso
        ln -sf $dir/$sha1.iso latest.iso
        find -mtime +4 \( -name "*.txt" -o -name "*.iso" \) -exec rm -vrf {} \;
        find -type d -empty -delete
fi
