#!/bin/bash
# Author: Daniele Rondina, geaaru@funtoo.org
# Description: Generate or Update the luet-portage-converter layer file of the
#              selected layer.
#
# Example:
# $> LAYER_NAME=funtoo-base sh scripts/create-pc-layer.sh

REPO_DIR=$(dirname ${BASH_SOURCE[0]})/..

LAYER_NAME=${LAYER_NAME:-}
PKGLIST=${PKGLIST:-/usr/share/macaroni/layers/${LAYER_NAME}/pkgslist}

LAYER_FILE=${LAYER_FILE:-${REPO_DIR}/portage-converter/layers/${LAYER_NAME}.yaml}

if [ -z "${LAYER_NAME}" ] ; then
  echo "Missing LAYER_NAME env"
  exit 1
fi

if [ ! -e ${PKGLIST} ] ; then
  echo "The file ${PKGLIST} doesn't exist."
  exit 1
fi

# Delete current packages list
yq d ${LAYER_FILE} 'packages' -i

echo "packages:" >> ${LAYER_FILE}

pkgs-checker pkglist  show -r ${PKGLIST} -j  -p  -v | \
  jq '.packages[] | "  - "+ .category + "/" + .name + ":" + .slot' -r | \
  sort >> ${LAYER_FILE}

