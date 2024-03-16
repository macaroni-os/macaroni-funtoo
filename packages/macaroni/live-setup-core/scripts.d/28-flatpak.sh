#!/bin/bash

setup_flatpak() {
  if [ "${FLATPAK_SETUP}" = "1" ] ; then
    flatpak --version
    res=$?
    if [ "$res" = "0" ] ; then
      flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
      # Initialize flatpak cache to have gnome-software catalog
      flatpak update --appstream
    fi
  fi
}
