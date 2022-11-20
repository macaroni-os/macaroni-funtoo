#!/bin/bash
# Author: Daniele Rondina, geaaru@funtoo.org
# Description: Script for download reposcan JSON files used by
#              luet-portage-converter tool.

CDN_PREFIX=${CDN_PREFIX:-https://images.macaroni.funtoo.org}
STABLE=${STABLE:-1}

KITS=(
  "browser-kit-next"
  "core-gl-kit-next"
  "core-hw-kit-next"
  "core-kit-next"
  "core-server-kit-next"
  "desktop-kit-next"
  "dev-kit-next"
  "editors-kit-next"
  "games-kit-next"
  "geaaru-kit-funtoo"
  "gnome-kit-next-3.36-prime"
  "haskell-kit-next"
  "java-kit-next"
  "kde-kit-next-5.24-release"
  "lang-kit-next"
  "lisp-scheme-kit-next"
  "llvm-kit-next"
  "mate-kit-next-1.24-prime"
  "media-kit-next"
  "ml-lang-kit-next"
  "net-kit-next"
  "perl-kit-next"
  "python-kit-next"
  "python-modules-kit-next"
  "qt-kit-next-5.15.2-release"
  "ruby-kit-next"
  "science-kit-next"
  "security-kit-next"
  "text-kit-next"
  "xfce-kit-next-4.16-release"
)

NAMESPACE=macaroni-terragon-dev-reposcan
if [ "$STABLE" = "1" ] ; then
  NAMESPACE=macaroni-terragon-reposcan
fi

mkdir -p ./kit_cache
for i in ${KITS[@]} ; do
  wget ${CDN_PREFIX}/${NAMESPACE}/${i} -O kit_cache/${i}
done
