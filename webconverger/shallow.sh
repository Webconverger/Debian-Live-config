test -d /tmp/chroot-old && sudo rm -rf /tmp/chroot-old
sudo mv chroot-old /tmp/chroot-old
sudo mv chroot chroot-old
sudo git clone --depth 1 -b master file:///home/hendry/test chroot
cd chroot && sudo git remote set-url origin git://github.com/Webconverger/webc.git
