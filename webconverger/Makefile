REPO = git://github.com/Webconverger/webc.git

all: chroot

# build from scratch
live: clean
	lb config
	sudo lb build

# use curated REPO
chroot: clean
	lb config --build-with-chroot false
	if test -d git-chroot; then sudo chroot git-chroot git pull; else sudo git clone $(REPO) git-chroot; fi
	sudo chroot git-chroot sh -c 'for s in .git-fixups/*; do sh $$s; done '
	sudo cp -a git-chroot chroot
	sudo lb binary_rootfs
	sudo mkdir binary/isolinux
	sudo lb binary_linux-image
	sudo lb binary_syslinux
	sudo lb binary_iso

clean:
	sudo lb clean
