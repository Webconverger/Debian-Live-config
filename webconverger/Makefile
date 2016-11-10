REPO := https://github.com/Webconverger/webc.git
BRANCH := master

# Check if live-build is new enough
LB_VERSION:=$(shell lb --version)
MIN_LB_VERSION:=4.0.0
TOONEW_LB_VERSION:=5.0~
ifneq ($(shell dpkg --compare-versions "$(LB_VERSION)" ge "$(MIN_LB_VERSION)"; echo $$?),0)
$(error live-build is too old, needs at least version $(MIN_LB_VERSION) $(CMP))
endif
ifneq ($(shell dpkg --compare-versions "$(LB_VERSION)" lt "$(TOONEW_LB_VERSION)"; echo $$?),0)
$(error live-build is too new, needs at less than version $(TOONEW_LB_VERSION) $(CMP))
endif

VERSION=$(shell cd chroot; git describe --always)

export SOURCE_DATE_EPOCH ?= $(shell git log -1 --pretty=%ct)

build: TYPE=iso-hybrid
build: binary

build-hdd: TYPE=hdd
build-hdd: binary

ifneq ($(shell id -u),0)
SUDO=sudo env SOURCE_DATE_EPOCH=$(SOURCE_DATE_EPOCH)
endif

VDI=binary.vdi
build-vbox-hdd: build-hdd
	# If there's already a vdi file, try to keep the UUID the same,
	# so you don't have to re-add the vdi file in Virtualbox.
	if [ -f "$(VDI)" ]; then \
		UUID="--uuid $$(VBoxManage showhdinfo $(VDI) | awk '$$1 == "UUID:" {print $$2}')"; \
		rm -f $(VDI); \
	fi; \
	VBoxManage convertfromraw live-image-i386 $(VDI) $$UUID

binary: clean
	# Check that the chroot has no changes
	[ -z "$$(cd chroot &&  git status --porcelain)" ] || \
	(echo "You have uncommitted changes in the chroot, bailing out now!" && false)

	test -d chroot || git clone --depth 1 -b $(BRANCH) $(REPO) chroot
	# Do a shallow clone to minimize image size. This only works
	# when using a file:// url (instead of plain path), so we use
	# ${CURDIR} to construct an absolute path). If chroot is already
	# a shallow clone, then just copy the .git directory
	if test -f chroot/.git/shallow; then \
		mkdir -p binary/live; \
		cp -r chroot/.git binary/live/filesystem.git; \
	else \
		git clone --no-local --depth 1 --bare file://$(CURDIR)/chroot/.git binary/live/filesystem.git; \
	fi
	git --git-dir=binary/live/filesystem.git remote set-url origin "$(REPO)"
	git --git-dir=binary/live/filesystem.git tag initial-revision
	# Make the repository look like a non-bare one. It will still
	# not have a worktree on disk, but in a running system, the
	# filesystem.git directory will be bindmounted as /.git, making
	# the root filesystem its worktree
	git --git-dir=binary/live/filesystem.git config --replace-all core.bare false
	lb config -b $(TYPE) --build-with-chroot false # --chroot-filesystem none
	# Remove logs for reproducibility; they contain timestamps
	rm -rf binary/live/filesystem.git/logs
	$(SUDO) lb binary_linux-image
	$(SUDO) lb binary_syslinux
	# Copy the template bootloader config, so the config can be
	# regenerated on upgrades (but only on an hdd image, since an
	# iso-hybrid image is not writable anyway).
	if [ "$(TYPE)" = hdd ]; then \
		$(SUDO) cp config/bootloaders/syslinux/live.cfg.in binary/boot; \
	fi
	# Build either a .iso or .img file, depending on the configured
	# image type
	$(SUDO) lb binary_reproducible
	$(SUDO) lb binary_iso
	$(SUDO) lb binary_hdd

clean:
	$(SUDO) lb clean --binary
	rm -f webc*.iso webc*.img webc*.txt
