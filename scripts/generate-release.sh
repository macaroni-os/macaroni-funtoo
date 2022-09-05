#!/bin/bash
# Author: Daniele Rondina <geaaru@funtoo.org>
# Description: This script is used to tag and create online release.

CODENAME=${CODENAME:-phoenix}
TAG_REPO=${TAG_REPO:-1}


main () {
  if [ -z "${GITHUB_TOKEN}" ] ; then
    echo "Missing GITHUB_TOKEN env"
    return 1
  fi

  if [ -z "${RELEASE}" ] ; then
    echo "Missing RELEASE env"
    return 1
  fi

  if [ "${TAG_REPO}" = 1 ] ; then
    echo "Tagging release v${RELEASE}-${CODENAME}..."
    git tag v${RELEASE}-${CODENAME}
    git push --tags
  fi

  export GORELEASER_CURRENT_TAG=v${RELEASE}-${CODENAME}

  goreleaser release --skip-validate --rm-dist
  return $?
}

main $@
exit $?
