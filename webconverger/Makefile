REPO := git://github.com/Webconverger/webc.git
OUTPUT := /srv/www/build.webconverger.org/output

# Check if live-build is new enough
LB_VERSION:=$(shell lb --version)
MIN_LB_VERSION:=3.0~a54
ifneq ($(shell dpkg --compare-versions "$(LB_VERSION)" ge "$(MIN_LB_VERSION)"; echo $$?),0)
$(error live-build is too old, needs at least version $(MIN_LB_VERSION) $(CMP))
endif

VERSION=$(shell cd chroot; git describe --always)

build: TYPE=iso-hybrid
build: binary
	mv binary.hybrid.iso webc-$(VERSION).iso
	./chroot.sh "dpkg-query -W" > webc-$(VERSION).txt

build-hdd: TYPE=hdd
build-hdd: binary
	mv binary.img webc-$(VERSION).img
	./chroot.sh "dpkg-query -W" > webc-$(VERSION).txt

binary: clean
	lb config -b $(TYPE) --build-with-chroot false # --chroot-filesystem none
	test -d chroot || sudo git clone --depth 1 $(REPO) chroot
	sudo chroot chroot sh -c 'for s in .git-fixups/*; do sh $$s; done'
	sudo lb binary_rootfs
	sudo lb binary_linux-image
	sudo lb binary_syslinux
	sudo lb binary_iso
	sudo lb binary_hdd

clean:
	sudo lb clean --binary
	rm -f webc*.iso webc*.img webc*.txt

deploy: build
	for i in webc*.iso; do mv $$i $(OUTPUT); echo "Redirect /latest.iso /$$i " > $(OUTPUT)/.htaccess ; done
	for i in webc*.txt; do mv $$i $(OUTPUT); echo "Redirect /latest.txt /$$i " >> $(OUTPUT)/.htaccess ; done
