#!/bin/bash

setup_openrc() {

  # Setup openrc runlevels
  whip hook openrc.openrc_setup
  whip hook polkit.polkit_setup

  if [ -n "${ENABLED_SERVICES}" ] ; then
    for srv in "${ENABLED_SERVICES[@]}"; do
        rc-update add "${srv}" default
    done
  fi

  if [ -n "${ENABLED_BOOT_SERVICES}" ] ; then
    for srv in "${ENABLED_BOOT_SERVICES[@]}"; do
        rc-update add "${srv}" boot
    done
  fi

  if [ -n "${ENABLED_SYSINIT_SERVICES}" ] ; then
    for srv in "${ENABLED_SYSINIT_SERVICES[@]}"; do
        rc-update add "${srv}" sysinit
    done
  fi

  return 0
}
