#!/bin/sh

set -e

TARGET_INITRD="binary/install/initrd.gz"
REPACK_TMPDIR="unpacked-initrd"

# cpio does not have a "extract to directory", so we must change directory
mkdir -p ${REPACK_TMPDIR}
cd ${REPACK_TMPDIR}
gzip -d < ../${TARGET_INITRD} | cpio -i --make-directories --no-absolute-filenames

# Overwrite banner
mv ../binary/install/banner.png ./usr/share/graphics/logo_debian.png

find | cpio -H newc -o | gzip -9 > ../${TARGET_INITRD}
cd ..
rm -rf ${REPACK_TMPDIR}
