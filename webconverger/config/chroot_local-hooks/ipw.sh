#!/bin/sh
echo "firmware-ipw2x00 firmware-ipw2x00/license/accepted boolean true" > /root/preseed
debconf-set-selections < /root/preseed
rm -f /root/preseed
