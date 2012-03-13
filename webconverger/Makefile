REPO = git://github.com/Webconverger/webc.git

# build from scratch
live: clean
	lb config
	sudo lb build

# Use curated rootfs
chroot:
	lb config --build-with-chroot false
	if test -d chroot; then sudo chroot chroot git pull; else sudo git clone $(REPO) chroot; fi
	sudo chroot chroot sh -c 'for s in .git-fixups/*; do sh $$s; done '
	sudo lb binary_rootfs
	sudo mkdir binary/isolinux
	sudo lb binary_linux-image
	sudo lb binary_syslinux
	sed -i "/append/s/$$/ ver=$$(cd chroot; git describe)/" binary/isolinux/live.cfg
	sudo lb binary_iso

clean:
	sudo lb clean
