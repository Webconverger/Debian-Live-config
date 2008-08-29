#!/bin/sh

set -e

# We prefer the GTK installer, so simply remove the 'newt' version
# to save space. To boot the GTK installer in 'newt' mode, simply
# append "DEBIAN_FRONTEND=newt" to the kernel command line.

rm -f binary/install/initrd.gz
rm -f binary/install/vmlinuz
