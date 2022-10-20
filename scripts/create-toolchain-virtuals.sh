#!/bin/bash

SCRIPT_DIR="$( dirname "${BASH_SOURCE[0]}" )"

kits=(
  "base"
  "boot"
  "java"
  "office"
  "emulation"
  "media-gfx"
  "server"
  "xorg-extra"
  "calamares"
  "python"
  "games"
)

for i in ${kits[@]} ; do
  TARGET_PKG=packages/toolchain/${i} SOURCE_PKGS_DIR=packages/atoms/${i}  ${SCRIPT_DIR}/toolchain-requires.sh
done
