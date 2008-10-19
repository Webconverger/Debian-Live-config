#!/bin/sh

set -e

log () {
	logger -t webconverger_late_cmd "$@"
}

USER="webc"

log "Removing packages"
in-target apt-get remove --yes aufs-modules-* squashfs-modules-* user-setup

log "Removing empty xorg.conf files"
rm -f /target/etc/X11/xorg.conf*

log "Setting Grub splash"
cp /cdrom/boot/grub/splash.xpm.gz /target/boot/grub/splash.xpm.gz
in-target update-grub
# Generated path is wrong
sed -i -e 's|//grub/splash.xpm.gz|/boot/grub/splash.xpm.gz|' /target/boot/grub/menu.lst

log "Workaround for older live-initramfs versions"
in-target chown -R 1000:1000 /home/${USER}

log "Remove passwords"
in-target passwd --delete root
in-target passwd --delete ${USER}

log "Setting up autologin"
sed -i -e "s|^\([^:]*:[^:]*:[^:]*\):.*getty.*\<\(tty[0-9]*\).*$|\1:/bin/login -f ${USER} </dev/\2 >/dev/\2 2>\&1|" /target/etc/inittab

log "Flushing filesystem buffers"
sync
