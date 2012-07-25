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

build-hdd: TYPE=hdd
build-hdd: binary

VDI=binary.vdi
build-vbox-hdd: build-hdd
	# If there's already a vdi file, try to keep the UUID the same,
	# so you don't have to re-add the vdi file in Virtualbox.
	if [ -f "$(VDI)" ]; then \
		UUID="--uuid $$(VBoxManage showhdinfo binary.vdi | awk '$$1 == "UUID:" {print $$2}')"; \
		rm -f binary.vdi; \
	fi; \
	VBoxManage convertfromraw binary.img binary.vdi $$UUID

binary: clean
	lb config -b $(TYPE) --build-with-chroot false # --chroot-filesystem none
	test -d chroot || sudo git clone --depth 1 $(REPO) chroot
	git clone --bare chroot/.git binary/live/filesystem.git
	sudo lb binary_linux-image
	sudo lb binary_syslinux
	sudo lb binary_iso
	sudo lb binary_hdd

clean:
	sudo lb clean --binary
	rm -f webc*.iso webc*.img webc*.txt

deploy: build
	mv binary.hybrid.iso webc-$(VERSION).iso
	./chroot.sh "dpkg-query -W" > webc-$(VERSION).txt
	for i in webc*.iso; do mv $$i $(OUTPUT); echo "Redirect /latest.iso /$$i " > $(OUTPUT)/.htaccess ; done
	for i in webc*.txt; do mv $$i $(OUTPUT); echo "Redirect /latest.txt /$$i " >> $(OUTPUT)/.htaccess ; done
