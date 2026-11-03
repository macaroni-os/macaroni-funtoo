#!/bin/bash

SCRIPT_DIR="$( dirname "${BASH_SOURCE[0]}" )"
ANISE_BUILD=${ANISE_BUILD:-anise-build}

kits=(
  "base"
  "base-extra"
  "base-python"
  "base-tools"
  "base-tools2"
)

for i in ${kits[@]} ; do
  # Generate the index of the directory
  ${ANISE_BUILD} tree genidx --only-upper-level --compress=false -t packages/atoms/${i} || {
    echo "Error on generate indexes for ${i}"
    exit 1
  }

  TARGET_PKG=packages/toolchain/${i} SOURCE_PKGS_DIR=packages/atoms/${i}  ${SCRIPT_DIR}/toolchain-requires.sh

  rm packages/atoms/${i}/.anise-idx.json
done
