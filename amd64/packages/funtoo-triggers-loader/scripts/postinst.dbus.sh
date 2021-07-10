#!/bin/bash
# Author: Daniele Rondina, geaaru@sabayonlinux.org

dbus_gen_machineid() {
  # Ensure unique id is generated and put it in /etc wrt #370451 but symlink
  # for DBUS_MACHINE_UUID_FILE (see tools/dbus-launch.c) and reverse
  # dependencies with hardcoded paths (although the known ones got fixed already)
  if [ ! -e "${EROOT}"/etc/machine-id ] ; then
    dbus-uuidgen --ensure="${EROOT}"/etc/machine-id
    if [ ! -e "${EROOT}"/var/lib/dbus ] ; then
      mkdir -p "${EROOT}"/var/lib/dbus
    fi

    ln -sf "${EPREFIX}"/etc/machine-id "${EROOT}"/var/lib/dbus/machine-id
  fi
}
