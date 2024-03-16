#!/bin/bash

setup_flatpak() {
  if [ "${FLATPAK_SETUP}" = "1" ] ; then
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
  fi
}
