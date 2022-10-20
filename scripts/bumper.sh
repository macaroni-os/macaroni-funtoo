#!/bin/bash
# Description: Script to create commit of new packages
#              divided by package. This will help on revert.
# Author: Daniele Rondina <geaaru@funtoo.org>

BUMPER_DIR="${BUMPER_DIR:-}"

main () {
  local version=""
  local cat=""
  local name=""
  local i=""

  if [ -z "${BUMPER_DIR}" ] ; then
    echo "Missing BUMPER_DIR variable with the package directory to parse"
    exit 1
  fi

  echo "Running bumper for directory ${BUMPER_DIR}..."

  pushd ${BUMPER_DIR}

  for i in $(git status .  -s | grep definition.yaml | awk '{ print $2 }' | sort -r) ; do
    version=$(yq r ${i} 'version')
    cat=$(yq r ${i} 'category')
    name=$(yq r ${i} 'name')
    dir=$(dirname ${i})

    pushd ${dir}

    git add .
    git commit -m "${cat}/${name}: Bump v.${version}" .

    popd

  done

  popd

  exit 0

}


main $@
