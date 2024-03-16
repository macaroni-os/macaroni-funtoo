#!/bin/bash

setup_additional_entities () {
  if [ -n "${ENTITIES_EXTRA}" ] ; then
   # kvm user used on setup s390x / ppc device from udev rule
   #missing="avahi-autoipd ddclient dhcpcd fdm pulse sddm pulse-access ushare utmp video vboxsf vboxusers vboxguest kvm"
   #missing="${missing}    adm   audio   bin   cdrom   console   daemon   dialout   disk   floppy   input   ipsec   kmem   locate   lp   lpadmin   mail   man   mem   messagebus   netdev   news   nobody   nogroup   plugdev   realtime   render   root   sys   tape   tss   tty   usb   users   utmp   uucp   video   wheel   halt   shutdown   operator   sync"

   for i in ${ENTITIES_EXTRA} ; do
     entities merge -s /usr/share/macaroni/entities -e $i
   done
  fi

  return 0
}

setup_general() {
  # Ensure right permission on /var
  chmod a+rw /var

  mkdir /var/tmp || true
  # Fix permission of /var/tmp (for example for flatpak)
  chmod a+rwx /var/tmp

  if [ -n "${DEF_TIMEZONE}" ] ; then
    echo "${DEF_TIMEZONE}" > /etc/timezone
  fi
  # Temporary. Maybe it's better set UTC here.
  ln -s /usr/share/zoneinfo/Europe/Rome /etc/localtime

  setup_additional_entities

  touch /etc/fstab

  echo "Creating /etc/inittab..."
  cp /var/lib/macaroni/inittab /etc/inittab -v

  # Ensure that the /root directory is present to
  # ensure that calamares-pkexec works correctly.
  mkdir -p /root || true

  # The suid is removed when the installation is completed.
  chmod u+s /usr/bin/pkexec

  whip hook dbus.dbus_setup
  whip hook dbus.dbus_gen_machineid

  return 0
}

