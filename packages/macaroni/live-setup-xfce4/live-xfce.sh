#!/bin/bash

if [ -n "$DEBUG" ] ; then
  set -x
fi

EROOT=${EROOT:-""}
DISPLAYMANAGER="sddm"
ENABLED_BOOT_SERVICES=(
  "dbus"
  "binfmt"
  "elogind"
  "hostname"
  "opentmpfiles-setup"
  "procfs"
  "root"
  "swap"
  "urandom"
)
ENABLED_SERVICES=(
  "avahi-daemon"
  "local"
  "bluetooth"
  # Temporay enable logger always. On ISO probably we can to maintain
  # this off.
  "metalog"
  "NetworkManager"
  "xdm"
  "virtualbox-guest-additions"
)
ENABLED_SYSINIT_SERVICES=(
  "udev-postmount"
  "udev-trigger"
  "udev-settle"
  "cgroups"
  "devfs"
  # dmcrypt and device-mapper is needed to support encrypted filesystem
  "device-mapper"
  "dmcrypt"
  "dmesg"
  "sysfs"
)
HOOKS=(
  "vboxguest.vboxguest_setup"
  "fonts.convert_pfb"
  "fonts.setup_all_fonts"
  "gtk.glib_update_schemas"
  "gtk.gtk_update_icons"
  "gtk.mime_update_db"
)

source ${EROOT}/var/lib/macaroni/live-core.sh

main_xfce() {
  main || return 1
}

main_xfce
exit $?
