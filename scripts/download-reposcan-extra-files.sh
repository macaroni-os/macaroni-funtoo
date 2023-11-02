#!/bin/bash
# Author: Daniele Rondina, geaaru@funtoo.org
# Description: Script for download reposcan JSON files used by
#              luet-portage-converter tool.

CDN_PREFIX=${CDN_PREFIX:-https://images.macaroni.funtoo.org}

KITS=(
  "geaaru-kit-funtoo"
)

NAMESPACE=extra-reposcan

mkdir -p ./kit_cache
for i in ${KITS[@]} ; do
  wget ${CDN_PREFIX}/${NAMESPACE}/${i} -O kit_cache/${i}
done
