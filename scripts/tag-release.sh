#!/bin/bash
# Description: Script to tag a new release

GORELEASER_OPTS=${GORELEASER_OPTS:---skip-validate --rm-dist}

main() {

  if [ -z "${GITHUB_TOKEN}" ] ; then
    echo "Missing GITHUB_TOKEN"
    return 1
  fi

  if [ -z "${GORELEASER_CURRENT_TAG}" ] ; then
    echo "Missing GITHUB_TOKEN"
    return 1
  fi

   goreleaser release ${GORELEASER_OPTS} || return 1
   return 0
}


main $@
exit $?
