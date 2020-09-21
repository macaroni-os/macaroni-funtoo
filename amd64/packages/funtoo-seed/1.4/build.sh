#!/bin/sh
set -ex
FUNTOO_RELEASE="1.4"
DATE_VERSION=$(echo "${PACKAGE_VERSION}" | cut -d'+' -f 2)
DATE_VERSION=${DATE_VERSION:0:10}
DATE_VERSION=${DATE_VERSION//./-}

FUNTOO_URL=https://build.funtoo.org/${FUNTOO_RELEASE}-release-std
FUNTOO_ARCH=x86-64bit
FUNTOO_SUBARCH=generic_64

wget ${FUNTOO_URL}/${FUNTOO_ARCH}/${FUNTOO_SUBARCH}/${DATE_VERSION}/stage3-${FUNTOO_SUBARCH}-${FUNTOO_RELEASE}-release-std-${DATE_VERSION}.tar.xz -O rootfs.tar.xz
