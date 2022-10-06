#!/bin/bash

setup_keymap() {
  local keymap_toset=
  local keymap_toset_model=

  for word in ${CMDLINE}; do
    case ${word} in
      console-setup/layoutcode=*)
        keymap_toset="${word/*=}"
        ;;
      console-setup/modelcode=*)
        keymap_toset_model="-${word/*=}"
        ;;
      KEYMAP=*)
        keymap_toset="${word/*=}"
        ;;
      keymap=*)
        keymap_toset="${word/*=}"
        ;;
      vconsole.keymap=*)
        keymap_toset="${word/*=}"
        ;;
      vconsole.keymap.model=*)
        keymap_toset_model="-${word/*=}"
        ;;
    esac
  done

  if [ -n "${keymap_toset}" ]; then
    aggregated_keymap="${keymap_toset}${keymap_toset_model}"
    echo "${aggregated_keymap}" > "/home/${LIVE_USER}/.Xkbmap"
    /sbin/keyboard-setup-2 "${aggregated_keymap}" all &> /dev/null
    if [ "${?}" = "0" ]; then
      openrc_running && /etc/init.d/keymaps restart --nodeps
      # systemd not needed here, this script runs before vconsole-setup
    fi
  fi
}
