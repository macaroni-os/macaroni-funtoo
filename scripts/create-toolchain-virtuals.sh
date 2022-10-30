#!/bin/bash

SCRIPT_DIR="$( dirname "${BASH_SOURCE[0]}" )"

kits=(
  "base"
  "base-extra"
  "base-python"
  "base-tools"
#  "boot"
#  "java"
#  "emulation"
#  "server"
#  "xorg-extra"
#  "python"
)

for i in ${kits[@]} ; do
  TARGET_PKG=packages/toolchain/${i} SOURCE_PKGS_DIR=packages/atoms/${i}  ${SCRIPT_DIR}/toolchain-requires.sh
done
