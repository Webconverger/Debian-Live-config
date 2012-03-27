REPO := git://github.com/Webconverger/webc.git
OUTPUT := /srv/www/build.webconverger.org/output

build: binary-hybrid.iso
	mv binary-hybrid.iso webc-$(shell cd chroot; git describe).iso
	./chroot.sh "dpkg-query -W" > webc-$(shell cd chroot; git describe).txt

binary-hybrid.iso: clean
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
	rm -f webc*.iso webc*.txt

deploy: build
	for i in webc*.iso; do mv $$i $(OUTPUT); echo "Redirect /latest.iso /$$i " > $(OUTPUT)/.htaccess ; done
	for i in webc*.txt; do mv $$i $(OUTPUT); echo "Redirect /latest.txt /$$i " >> $(OUTPUT)/.htaccess ; done
