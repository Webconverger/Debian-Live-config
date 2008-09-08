#!/bin/sh

set -e

TARGET_INITRD="binary/install/gtk/initrd.gz"
REPACK_TMPDIR="unpacked-initrd"

# cpio does not have a "extract to directory", so we must change directory
mkdir -p ${REPACK_TMPDIR}
cd ${REPACK_TMPDIR}
gzip -d < ../${TARGET_INITRD} | cpio -i --make-directories --no-absolute-filenames

# Overwrite banner
mv ../binary/install/banner.png ./usr/share/graphics/logo_debian.png

# Import patch from #498143
patch -p1 <<EOF
--- a/var/lib/dpkg/info/cdrom-detect.postinst
+++ b/var/lib/dpkg/info/cdrom-detect.postinst
@@ -44,6 +44,28 @@ do
 		fi
 	done
 
+	# Try disk partitions masquerading as Debian CDs for Debian Live
+	# "usb-hdd" images. Only vfat and ext are supported.
+	modprobe vfat >/dev/null 2>&1 || true
+	for device in \$(list-devices partition); do
+		if mount -t vfat -o ro,exec \$device /cdrom ||
+		   mount -t ext2 -o ro,exec \$device /cdrom; then
+			log "Pseudo CD-ROM mount succeeded: device=\$device"
+
+			# Test whether it's a Debian CD
+			if [ -e /cdrom/.disk/info ]; then
+				mounted=1
+				db_set cdrom-detect/cdrom_device \$device
+				break
+			else
+				log "Ignoring pseudo CD-ROM device \$device - it is not a Debian CD"
+				umount /cdrom 2>/dev/null || true
+			fi
+		else
+			log "Psuedo CD-ROM mount failed: device=\$device"
+		fi
+	done
+
 	if [ "\$mounted" = "1" ]; then
 		break
 	fi
-- 
1.5.6.5
EOF

find | cpio -H newc -o | gzip -9 > ../${TARGET_INITRD}
cd ..
rm -rf ${REPACK_TMPDIR}
