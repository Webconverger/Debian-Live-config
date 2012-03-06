INFILES = config/binary_debian-installer/banner.orig config/bootloaders/isolinux/splash.orig config/includes.chroot/etc/webc/bg.orig
OUTFILES = $(addsuffix .png, $(basename $(INFILES)))
TODAY=$(shell date +%Y-%m-%d)

%.png : %.orig
	convert -size 75x14 xc:none -gravity center -pointsize 10 \
		-stroke black -strokewidth 2 -annotate 0 $(TODAY) \
		-background none -shadow 150x3+0+0 +repage \
		-stroke none -fill white     -annotate 0 $(TODAY) \
		$< +swap -gravity south -geometry +260-0 \
		-composite $@

all: clean $(OUTFILES)
	lb config
	sudo lb build

clean:
	sudo lb clean
	rm -f $(OUTFILES)
