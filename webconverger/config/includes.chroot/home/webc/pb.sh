#!/bin/bash
# pb = persistent browser
# Keep the browser running and clean between sessions in $WEBCHOME
# hendry@webconverger.com
WEBCHOME=/home/webc

logger xsession invoked

! grep -qs noroot /proc/cmdline && {
	set -x
	exec 2> ~/pb.log
}

homepage="$1"

for x in $(cat /proc/cmdline); do
	case $x in
		homepage=*)
			homepage="$( /bin/busybox httpd -d ${x#homepage=} )"
			;;
		kioskresetstation=*) # For killing the browser after a number of minutes of idleness
			exec /usr/bin/kioskresetstation ${x#kioskresetstation=} &
			;;
		locales=*)
			export LANG=$( locale -a | grep ^${x#locales=}_...utf8 )
			;;
	esac
done

# disable bell
xset b 0 0

# white background http://webconverger.org/artwork/
xsetroot -solid "#ffffff"

# only when noroot is supplied, we use Webc's WM dwm.web
wm="/usr/bin/dwm.default"
grep -qs noroot /proc/cmdline && wm="/usr/bin/dwm.web"
exec $wm &

# hide the cursor by default, showcursor to override
! grep -qs showcursor /proc/cmdline && exec /usr/bin/unclutter &

# Stop (ab)users breaking the loop to restart the exited browser
trap "echo Unbreakable!" SIGINT SIGTERM

grep -qs compose /proc/cmdline && setxkbmap -option "compose:rwin" && logger "Compose key setup"

# Set default homepage if homepage cmdline isn't set
test $homepage = "" &&  homepage="http://portal.webconverger.com/"

# if no-x-background is unset, try setup a background from homepage sans query
! grep -qs noxbg /proc/cmdline && {
	cp /etc/webc/bg.png $WEBCHOME/bg.png
	wget --timeout=5 ${homepage}/bg.png -O $WEBCHOME/bg.png.tmp 
	file $WEBCHOME/bg.png.tmp | grep -qs "image data" && {
		mv $WEBCHOME/bg.png.tmp $WEBCHOME/bg.png
	}
	xloadimage -quiet -onroot -center $WEBCHOME/bg.png
}

# No screen blanking - needed for Digital signage
grep -qs noblank /proc/cmdline && {
	logger noblank
	xset s off 
	xset -dpms
}


# TODO: Maybe merge MAC finding code?
# https://github.com/Webconverger/Debian-Live-config/blob/master/webconverger/config/includes.chroot/etc/network/if-up.d/ping
for i in $(ls /sys/class/net)
do
	test $(basename $i) = "lo" && continue
	mac=$(cat /sys/class/net/$i/address | tr -d ":")
	test "$mac" && break
done
x=$(echo $homepage | sed "s,MACID,$mac,")
shift

while true
do

	if test -x /usr/bin/iceweasel
	then
		rm -rf $WEBCHOME/.mozilla/
		iceweasel "$x" "$@"
		rm -rf $WEBCHOME/.mozilla/
	fi

	rm -rf $WEBCHOME/.adobe
	rm -rf $WEBCHOME/.macromedia
	rm -rf $WEBCHOME/Downloads

done
