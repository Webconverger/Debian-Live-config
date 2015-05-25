#!/bin/bash
# ./chroot.sh  "dpkg-query -W"

Chroot ()
{
	CHROOT="${1}"; shift
	COMMANDS="${@}"

		/usr/sbin/chroot "${CHROOT}" /usr/bin/env -i HOME="/root" PATH="/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin" TERM="xterm"  ${COMMANDS}

	return "${?}"
}

if test $# -gt 0
then
	Chroot chroot $@
else

	mount -o bind /dev chroot/dev
	mount -o bind /sys chroot/sys
	mount -o bind /proc chroot/proc
	chroot chroot /usr/bin/env -i HOME="/root" PATH="/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin" /bin/bash
	umount chroot/sys
	umount chroot/proc
	umount chroot/dev



fi
