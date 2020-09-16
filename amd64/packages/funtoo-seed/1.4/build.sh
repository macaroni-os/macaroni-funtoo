#!/bin/sh
set -ex
apk --no-cache add ca-certificates tar wget xz rsync

FUNTOO_RELEASE="1.4"
DATE_VERSION=$(echo "${PACKAGE_VERSION}" | cut -d'+' -f 2)
DATE_VERSION=${DATE_VERSION//./-}

FUNTOO_URL=https://build.funtoo.org/${FUNTOO_RELEASE}-release-std
FUNTOO_ARCH=x86-64
FUNTOO_SUBARCH=generic_64

wget ${FUNTOO_URL}/${FUNTOO_ARCH}/${FUNTOO_SUBARCH}/${DATE_VERSION}/stage3-${FUNTOO_SUBARCH}-${FUNTOO_RELEASE}-release-std-${DATE_VERSION}.tar.xz -O /rootfs.tar.xz

mkdir /temp
cd /temp && tar -xJf /rootfs.tar.xz --xattrs --numeric-owner && rm /rootfs.tar.xz
