#!/bin/bash
# ./chroot.sh  "dpkg-query -W"

Chroot ()
{
	CHROOT="${1}"; shift
	COMMANDS="${@}"

		sudo /usr/sbin/chroot "${CHROOT}" /usr/bin/env -i HOME="/root" PATH="/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin" TERM="xterm"  ${COMMANDS}

	return "${?}"
}

#sudo mount -o bind /sys $chroot/sys
#sudo mount -o bind /proc $chroot/proc
#sudo umount $chroot/sys
#sudo umount $chroot/proc

if test $# -gt 0
then
	Chroot chroot $@
else
	sudo chroot chroot
fi
