#!/bin/bash
# ./chroot.sh  "dpkg-query -W"

Chroot ()
{
	CHROOT="${1}"; shift
	COMMANDS="${@}"

		sudo /usr/sbin/chroot "${CHROOT}" /usr/bin/env -i HOME="/root" PATH="/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin" TERM="xterm"  ${COMMANDS}

	return "${?}"
}

if test $# -gt 0
then
	Chroot chroot $@
else
sudo mount -o bind /dev chroot/dev
sudo mount -o bind /sys chroot/sys
sudo mount -o bind /proc chroot/proc
sudo chroot chroot
sudo umount chroot/sys
sudo umount chroot/proc
sudo umount chroot/dev



fi
