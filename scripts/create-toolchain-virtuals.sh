#!/bin/bash

SCRIPT_DIR="$( dirname "${BASH_SOURCE[0]}" )"

kits=(
  "office"
  "base"
  "emulation"
  "browsers"
  "boot"
)

for i in ${kits[@]} ; do
  TARGET_PKG=packages/toolchain/${i} SOURCE_PKGS_DIR=packages/atoms/${i}  ${SCRIPT_DIR}/virtual-core-requires.sh
done
