#!/bin/bash

set -e

BRANCH=$(echo $RELEASE | sed -e 's/[.][0-9]*$//g')
REPO_DIR=$(dirname ${BASH_SOURCE[0]})/..

main () {
  if [ -z "$RELEASE" ] ; then
    echo "Missing new kernel version"
    return 1
  fi

  # Bump seed
  yq w -i ${REPO_DIR}/packages/seeds/macaroni-kernel-${BRANCH}/definition.yaml 'labels.[kernel.version]' ${RELEASE}
  yq w -i ${REPO_DIR}/packages/seeds/macaroni-kernel-${BRANCH}/definition.yaml 'version' ${RELEASE}

  modules=(
    nvidia-drivers
    rtw89
    virtualbox-guest-additions
    virtualbox-modules
    zfs-kmod
  )

  for i in ${modules[@]} ; do
    yq w -i ${REPO_DIR}/packages/kernels/${BRANCH}/${i}/definition.yaml 'labels.[kernel.version]' ${RELEASE}
    luet-build tree bump -f ${REPO_DIR}/packages/kernels/${BRANCH}/${i}/definition.yaml
  done
}

main $@
exit $?
