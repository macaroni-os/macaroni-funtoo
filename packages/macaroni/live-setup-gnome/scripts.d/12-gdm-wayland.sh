#!/bin/bash
# Author: Daniele Rondina, geaaru@macaronios.org

setup_gdm_wayland() {
  if [ "${GNOME_WAYLAND_ENABLE}" = "1" ] ; then
    sed -i -e 's|^WaylandEnable=.*|WaylandEnable=true|g' /etc/gdm/custom.conf
  fi
}
