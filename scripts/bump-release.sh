#!/bin/bash
# Description: Bump packages needed for a new release.
#
# NOTE: this script MUST be execute at the repo root level.

files2bump=(
  "packages/atoms/release/sys-apps/baselayout/definition.yaml"
  "packages/atoms/release/sys-apps/lsb-release/definition.yaml"
)


main() {
  if [ -z "${RELEASE}" ] ; then
    echo "Missing mandatory RELEASE env variable."
    return 1
  fi

  for i in ${files2bump[@]} ; do
    echo $i
    # Read existing release
    previous=$(yq4 eval '.labels."macaroni.version"' $i)

    yq4 eval -i ".labels.\"macaroni.version\" = \"${RELEASE}\"" $i

    echo "For file ${i} upgrade from ${previous} to ${RELEASE}..."

    luet-build tree bump -f $i
  done

  return 0
}

main $@
exit $?
