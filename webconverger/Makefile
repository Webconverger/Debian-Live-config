INFILES = config/bootloaders/isolinux/splash.orig config/includes.chroot/etc/webc/bg.orig
OUTFILES = $(addsuffix .png, $(basename $(INFILES)))
TODAY=$(shell date +%Y-%m-%d)

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

chroot: clean $(OUTFILES)
	lb config --build-with-chroot false
	test -d github_chroot || git clone git://github.com/Webconverger/webc.git github_chroot
	test -d github_chroot && cp -r github_chroot chroot
	(cd chroot && git pull && for s in .git-fixups/*; do sh $s; done )
	sudo lb binary_rootfs
	sudo mkdir binary/isolinux
	sudo lb binary_linux-image
	sudo lb binary_syslinux
	sudo lb binary_iso

clean:
	sudo lb clean
	rm -f $(OUTFILES)
