#!/bin/bash
# Author: Daniele Rondina, geaaru@macaronios.org

setup_gdm_wayland() {
  local wmode="false"
  if [ "${GNOME_WAYLAND_ENABLE}" = "1" ] ; then
    wmode="true"
  fi
  sed -i -e "/^[[:space:]]*#\?[[:space:]]*WaylandEnable[[:space:]]*=/c\WaylandEnable=$WMODE" \
    /etc/gdm/custom.conf
}
