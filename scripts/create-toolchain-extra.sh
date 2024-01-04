#!/bin/bash

SCRIPT_DIR="$( dirname "${BASH_SOURCE[0]}" )"
LUET_BUILD=${LUET_BUILD:-luet-build}

kits=(
  "net"
  "lang"
  "dev"
  "server"
  "db"
  "telemetry"
  "java"
  "xorg"
  "tools"
)

for i in ${kits[@]} ; do
  # Generate the index of the directory
  ${LUET_BUILD} tree genidx --only-upper-level --compress=false -t packages/atoms-extra/${i} || {
    echo "Error on generate indexes for ${i}"
    exit 1
  }
  TARGET_PKG=packages/toolchain/extra-${i} SOURCE_PKGS_DIR=packages/atoms-extra/${i}  ${SCRIPT_DIR}/toolchain-requires.sh

  rm packages/atoms-extra/${i}/.anise-idx.json
done
