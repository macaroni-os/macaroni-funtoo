#!/bin/bash

if [ -n "$DEBUG" ] ; then
  set -x
fi

EROOT=${EROOT:-""}
DISPLAYMANAGER="gdm"
PLYMOUTH_THEME="funtoo"
DEFAULT_XSESSION="gnome"
ENABLED_BOOT_SERVICES=(
  "dbus"
  "binfmt"
  "elogind"
  "hostname"
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
  "zram-init"
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
  "colord.colord_setup"
  "gdm.setup"
  "gtk.postinst"
)
GNOME_SHELL_EXTS=(
  "dash-to-dock"
  "desktop-icons"
  "dynamic-panel-transparency"
)

source ${EROOT}/var/lib/macaroni/live-core.sh

main_gnome() {
  main || return 1
}

main_gnome
exit $?
