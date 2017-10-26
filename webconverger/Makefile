REPO := https://github.com/Webconverger/webc.git
BRANCH := master

# Check if live-build is new enough
LB_VERSION:=$(shell lb --version)
# This version has the patches for reproducible builds and corrects the
# syslinux mbr.bin path.
MIN_LB_VERSION:=1:20161202
#TOONEW_LB_VERSION:=5.0~

ifneq ($(shell dpkg --compare-versions "$(LB_VERSION)" ge "$(MIN_LB_VERSION)"; echo $$?),0)
$(error live-build is too old, needs at least version $(MIN_LB_VERSION) $(CMP))
endif
#ifneq ($(shell dpkg --compare-versions "$(LB_VERSION)" lt "$(TOONEW_LB_VERSION)"; echo $$?),0)
#$(error live-build is too new, needs at less than version $(TOONEW_LB_VERSION) $(CMP))
#endif

VERSION=$(shell cd chroot; git describe --always)

export SOURCE_DATE_EPOCH ?= $(shell git --git-dir=chroot/.git log -1 --pretty=%ct)

build: TYPE=iso-hybrid
build: binary

build-hdd: TYPE=hdd
build-hdd: binary

ifneq ($(shell id -u),0)
SUDO=sudo env SOURCE_DATE_EPOCH=$(SOURCE_DATE_EPOCH)
endif

VDI=binary.vdi
build-vbox-hdd: build-hdd
	# Ask VBoxManage what UUID to use. If the VDI file is registered
	# with VirtualBox, the UUID from its database is used
	# (regardless of whether the VDI file exists and its current
	# UUID). If not, the current UUID is used. This prevents
	# problems with Virtualbox seeing a different UUID from what it
	# expected.
	if VBoxManage showhdinfo $(VDI) >/dev/null 2>/dev/null ; then \
		UUID="--uuid $$(VBoxManage showhdinfo $(VDI) | awk '$$1 == "UUID:" {print $$2}')"; \
	fi; \
	rm -f $(VDI); \
	IMG="$(wildcard live-image-i386 live-image-i386.img)"; \
	VBoxManage convertfromraw $$IMG $(VDI) $$UUID

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
	du -sh binary/live/filesystem.git/
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
	# Remove index for reproducibility; contains timestamps and
	# non-deterministic inode numbers.
	rm -rf binary/live/filesystem.git/index
	$(SUDO) lb binary_linux-image
	$(SUDO) lb binary_syslinux \
	  || (printf 1>&2 "  %s\n" "" \
		"If live-build complains about /usr/share/ISOLINUX, or" \
		"/usr/share/SYSLINUX, you are likely running a live-build" \
		"version without http://bugs.debian.org/864629 applied." \
		"Either upgrade to a version with that patch, or create a" \
		"symlink /usr/share/ISOLINUX -> /usr/lib/ISOLINUX and/or" \
		"/usr/share/SYSLINUX -> /usr/lib/SYSLINUX." "" \
	      && false)

	# Copy the template bootloader config, so the config can be
	# regenerated on upgrades (but only on an hdd image, since an
	# iso-hybrid image is not writable anyway).
	if [ "$(TYPE)" = hdd ]; then \
		$(SUDO) cp config/bootloaders/syslinux/live.cfg.in binary/boot; \
	fi

	# Remove hardlinked copies of initrd and vmlinuz that are not
	# really needed, but cause problems when generating a FAT image
	# (that does not support hardlinks). This happens from
	# live-build version 1:20161202, until https://bugs.debian.org/873640
	# is merged.
	$(SUDO) rm -f binary/live/initrd.img-*
	$(SUDO) rm -f binary/live/vmlinuz-*

	# "Clamp" the time to SOURCE_DATE_EPOCH when the file is more recent to keep
	# the original times for files that have not been created or modified during
	# the build process:
	$(SUDO) find binary -newermt "@$(SOURCE_DATE_EPOCH)" -print0 | $(SUDO) xargs -0r touch --no-dereference --date="@$(SOURCE_DATE_EPOCH)"

	# Build either a .iso or .img file, depending on the configured
	# image type
	$(SUDO) lb binary_iso
	$(SUDO) lb binary_hdd

clean:
	$(SUDO) lb clean --binary
	rm -f webc*.iso webc*.img webc*.txt $(VDI)
