#!/bin/bash
# Author: Daniele Rondina, geaaru@funtoo.org
# Description: Script for download reposcan JSON files used by
#              luet-portage-converter tool.

CDN_PREFIX=${CDN_PREFIX:-https://images.macaroni.funtoo.org}
STABLE=${STABLE:-1}

KITS=(
  "browser-kit-1.4-release"
  "core-gl-kit-2.0-release"
  "core-hw-kit-1.4-release"
  "core-kit-1.4-release"
  "core-server-kit-1.4-release"
  "desktop-kit-1.4-release"
  "dev-kit-1.4-release"
  "editors-kit-1.4-release"
  "games-kit-1.4-release"
  "gnome-kit-3.36-prime"
  "haskell-kit-1.4-release"
  "java-kit-1.4-release"
  "kde-kit-5.20-release"
  "lang-kit-1.4-release"
  "lisp-scheme-kit-1.4-release"
  "llvm-kit-1.4-release"
  "mate-kit-1.24-prime"
  "media-kit-1.4-release"
  "ml-lang-kit-1.4-release"
  "net-kit-1.4-release"
  "nokit-1.4-release"
  "perl-kit-5.32-release"
  "python-kit-3.7-release"
  "python-modules-kit-1.4-release"
  "qt-kit-5.15.2-release"
  "ruby-kit-2.7-prime"
  "science-kit-1.4-release"
  "security-kit-1.4-release"
  "text-kit-1.4-release"
  "xfce-kit-4.16-release"
)

NAMESPACE=macaroni-funtoo-dev-reposcan
if [ "$STABLE" = "1" ] ; then
  NAMESPACE=macaroni-funtoo-reposcan
fi

mkdir -p ./kit_cache
for i in ${KITS[@]} ; do
  wget ${CDN_PREFIX}/${NAMESPACE}/${i} -O kit_cache/${i}
done
