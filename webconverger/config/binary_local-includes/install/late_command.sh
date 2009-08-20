#!/bin/sh -e

log () {
	logger -t webconverger_late_cmd "$@"
}

USER="webc"

log "Removing packages"
in-target apt-get remove --yes aufs-modules-* user-setup

log "Removing empty xorg.conf files"
rm -f /target/etc/X11/xorg.conf*

log "Setting Grub splash"
cp /cdrom/boot/grub/splash.xpm.gz /target/boot/grub/splash.xpm.gz
in-target update-grub
echo "splashimage /boot/grub/splash.xpm.gz" >> /target/boot/grub/menu.lst

log "Remove passwords"
in-target passwd --delete root
in-target passwd --delete ${USER}

log "Setting up autologin"
sed -i -e "s|^\([^:]*:[^:]*:[^:]*\):.*getty.*\<\(tty[0-9]*\).*$|\1:/bin/login -f ${USER} </dev/\2 >/dev/\2 2>\&1|" /target/etc/inittab

log "Setting up Webconverger sources.list"
cp /etc/apt/sources.list /target/etc/apt/sources.list

log "Flushing filesystem buffers"
sync
