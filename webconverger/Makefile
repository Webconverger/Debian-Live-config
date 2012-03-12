INFILES = config/bootloaders/isolinux/splash.orig config/includes.chroot/etc/webc/bg.orig
OUTFILES = $(addsuffix .png, $(basename $(INFILES)))
TODAY=$(shell date +%Y-%m-%d)
REPO = git://github.com/Webconverger/webc.git

%.png : %.orig
	convert -size 75x14 xc:none -gravity center -pointsize 10 \
		-stroke black -strokewidth 2 -annotate 0 $(TODAY) \
		-background none -shadow 150x3+0+0 +repage \
		-stroke none -fill white     -annotate 0 $(TODAY) \
		$< +swap -gravity south -geometry +250-0 \
		-composite $@

live: clean $(OUTFILES)
	lb config
	sudo lb build

chroot: $(OUTFILES)
	lb config --build-with-chroot false
	if test -d chroot; then sudo chroot chroot git pull; else sudo git clone $(REPO) chroot; fi
	sudo chroot chroot sh -c 'for s in .git-fixups/*; do sh $$s; done '
	sudo lb binary_rootfs
	sudo mkdir binary/isolinux
	sudo lb binary_linux-image
	sudo lb binary_syslinux
	sudo lb binary_iso

clean:
	sudo lb clean
	rm -f $(OUTFILES)
