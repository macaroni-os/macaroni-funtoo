#!/bin/bash

SCRIPT_DIR="$( dirname "${BASH_SOURCE[0]}" )"
LUET_BUILD=${LUET_BUILD:-luet-build}

kits=(
  "base"
  "base-extra"
  "base-python"
  "base-tools"
  "base-tools2"
  "base-xorg"
  "base-xorg2"
  "fonts"
  "base-gtk"
  "base-gtk2"          # race7 (vala)
  "base-editors"       # race7

  "xorg-base"          # race8
  "base-net"           # race8
  "base-lang"          # race8
  "base-fs"            # race8

  "db"                 # race9 (db)
  "base-qt"            # race9 (qtcore)
  "base-audio"         # race9
  "base-video"         # race9

  "base-multimedia"    # race10 (pulseaudio, sdl)
  "base-text"          # race10 (latex stuff deps)

  "base-latex"         # race11 (latex stuff)
  "base-multimedia2"   # race11 (ffmpeg, alsa-plugins)
  "boot"               # race11 (grub, efi)
  "shells"             # race11 (zsh, tcsh, etc.)


  "base-qt2"           # race12 (qtwebkit, qtmultimedia)
  "base-gnome"         # race12 (gnome deps)

  "base-gnome2"        # race13
  "portage-tools"      # race13 (eix, layman)

  "base-gnome3"        # race14
  "release"            # race14 (to move after base with baselayout)
  "base-net2"          # race14
  "nvidia"             # race14
  "base-multimedia3"   # race14

  "base-gnome4"        # race15
  "base-kde"           # race15
  "tools"              # race15
  "base-latex2"        # race15
  "firmware"           # race15
  "base-lang2"         # race15

  "gnome-extra"        # race16
  "telemetry"          # race16
  "x11-misc"           # race16
  "base-kde2"          # race16
  "gnome-games"        # race16
  "python-extra"       # race16
  "java"               # race16
  "emulation"          # race16
  "base-multimedia4"   # race16
  "lxqt"               # race16

  "xfce"               # race17
  "funtoo"             # race17
  "base-kde3"          # race17
  "i3"                 # race17
  "desktop"            # race17
  "devtools"           # race17
  "base-text2"         # race17
  "e17"                # race17
  "browsers"           # race17

  "base-kde4"          # race18
  "office"             # race18
  "printers"           # race18
  "emulation2"         # race18
  "server"             # race18
  "x11-misc2"          # race18
  "desktop2"           # race18
  "power"              # race18

  #"printers"           # race18
  #"php"                # race18

  "base-kde5"          # race19

  "base-kde6"          # race20
  "kde-games"          # race20
)

for i in ${kits[@]} ; do

  # Generate the index of the directory
  ${LUET_BUILD} tree genidx --only-upper-level --compress=false -t packages/atoms/${i} || {
    echo "Error on generate indexes for ${i}"
    exit 1
  }

  TARGET_PKG=packages/toolchain/${i} SOURCE_PKGS_DIR=packages/atoms/${i}  ${SCRIPT_DIR}/toolchain-requires.sh
done
