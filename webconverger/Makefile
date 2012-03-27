REPO = git://github.com/Webconverger/webc.git

all: chroot

chroot: clean
	lb config --build-with-chroot false # --chroot-filesystem none
	if test -d chroot; then sudo chroot chroot git pull; else sudo git clone $(REPO) chroot; fi
	sudo chroot chroot sh -c 'for s in .git-fixups/*; do sh $$s; done '
	sudo lb binary_rootfs
	sudo mkdir binary/isolinux
	sudo lb binary_linux-image
	sudo lb binary_syslinux
	sudo lb binary_iso

clean:
	sudo lb clean --binary
