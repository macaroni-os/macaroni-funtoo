#!/bin/bash

SCRIPT_DIR="$( dirname "${BASH_SOURCE[0]}" )"

kits=(
  "dev"
  "net"
  "emulation"
  "gnome"
  "php"
  "media"
  "desktop"
  "tools"
  "automation"
)

for i in ${kits[@]} ; do
  TARGET_PKG=packages/toolchain/extra-${i} SOURCE_PKGS_DIR=packages/atoms-extra/${i}  ${SCRIPT_DIR}/toolchain-requires.sh
done
