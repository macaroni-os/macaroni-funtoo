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
    lkrg
  )

  common_modules=(
    nvidia-drivers
    zfs-common
    virtualbox-modules
  )

  for i in ${modules[@]} ; do
    if [ -d ${REPO_DIR}/packages/kernels/${BRANCH}/${i} ] ; then
      yq w -i ${REPO_DIR}/packages/kernels/${BRANCH}/${i}/definition.yaml 'labels.[kernel.version]' ${RELEASE}
      luet-build tree bump -f ${REPO_DIR}/packages/kernels/${BRANCH}/${i}/definition.yaml
    fi
  done

  if [ ${BRANCH} = "5.10" ] ; then
    for i in ${common_modules[@]} ; do
      if [ -d ${REPO_DIR}/packages/kernels/common/${i} ] ; then
        luet-build tree bump -f ${REPO_DIR}/packages/kernels/common/${i}/definition.yaml
      fi
    done
  fi
}

main $@
exit $?
