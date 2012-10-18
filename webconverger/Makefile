REPO := git://github.com/Webconverger/webc.git
OUTPUT := /srv/www/build.webconverger.org/output

# Check if live-build is new enough
LB_VERSION:=$(shell lb --version)
MIN_LB_VERSION:=3.0~a62
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
	# Check that the chroot has no changes
	[ -z "$$(cd chroot &&  git status --porcelain)" ] || (echo "You have uncommitted changes in the chroot, bailing out now!" && false)
	test -d chroot || sudo git clone --depth 1 $(REPO) chroot
	# Do a shallow clone to minimize image size. This only works
	# when using a file:// url (instead of plain path), so we use
	# ${CURDIR} to construct an absolute path).
	git clone --no-local --depth 1 --bare file://$(CURDIR)/chroot/.git binary/live/filesystem.git || cp -rv chroot/.git binary/live/filesystem.git
	git --git-dir=binary/live/filesystem.git remote set-url origin "$(REPO)"
	git --git-dir=binary/live/filesystem.git tag initial-revision
	# Make the repository look like a non-bare one. It will still
	# not have a worktree on disk, but in a running system, the
	# filesystem.git directory will be bindmounted as /.git, making
	# the root filesystem its worktree
	git --git-dir=binary/live/filesystem.git config --replace-all core.bare false
	lb config -b $(TYPE) --build-with-chroot false # --chroot-filesystem none
	sudo lb binary_linux-image
	sudo lb binary_syslinux
	# Copy the template bootloader config, so the config can be
	# regenerated on upgrades (but only on an hdd image, since an
	# iso-hybrid image is not writable anyway).
	if [ "$(TYPE)" = hdd ]; then \
		sudo cp config/bootloaders/syslinux/live.cfg.in binary/boot; \
	fi
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
