#!/bin/bash
# Author: Daniele Rondina, geaaru@funtoo.org
# Description: Script to run inside the chroot of the installed system.

set -ex

rootfs=$1
hostname=$2

sed -i -e "s|^hostname=.*|hostname=\"${hostname}\"|g" /etc/conf.d/hostname
sed -i -e "s|macaroni-funtoo|${hostname}|g" /etc/hosts

# Temporary until the ISO build process cleanup this
rm -rf /luetdb || true

exit 0
