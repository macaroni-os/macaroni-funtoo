#!/bin/bash

SCRIPT_DIR="$( dirname "${BASH_SOURCE[0]}" )"
LUET_BUILD=${LUET_BUILD:-luet-build}

kits=(
  "base" # mark-base
  "base-extra" # macaroni-mark-base
  "base-python" # macaroni-mark-race1
  "base-tools" # macaroni-mark-race2
  "base-tools2" # macaroni-mark-race3

  "net"   # macaroni-mark-race4

  "lang"  # macaroni-mark-race5

  "dev-tools"   # macaroni-mark-race6

  "server"      # race7
  "text"        # race7

  "xorg-base"        # race8

  "xorg-base2"        # race9

  "xorg-base3"        # race10
  "latex"             # race10
  "telemetry"         # race10
  "base-php"         # race10

  "db"                # race11
  "latex-extra"       # race11
  "java"              # race11
  "php-extra"         # race11

  "tools"               # race12
  "python-extra"        # race12
)

for i in ${kits[@]} ; do

  # Generate the index of the directory
  ${LUET_BUILD} tree genidx --only-upper-level --compress=false -t packages/atoms/${i} || {
    echo "Error on generate indexes for ${i}"
    exit 1
  }

  TARGET_PKG=packages/toolchain/${i} SOURCE_PKGS_DIR=packages/atoms/${i}  ${SCRIPT_DIR}/toolchain-requires.sh

  rm packages/atoms/${i}/.anise-idx.json || true
done
