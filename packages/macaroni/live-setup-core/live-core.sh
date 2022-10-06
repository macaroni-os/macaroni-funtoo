#!/bin/bash

#. /var/lib/macaroni/live-functions.sh

if [ -n "$DEBUG" ] ; then
  set -x
fi

EROOT=${EROOT:-""}
ENTITIES_EXTRA=${ENTITIES_EXTRA:-"avahi-autoipd ddclient dhcpcd fdm pulse sddm pulse-access ushare utmp video vboxsf vboxusers vboxguest kvm"}
LIVE_USER=macaroni
CMDLINE=${CMDLINE:-$(cat /proc/cmdline 2> /dev/null)}
SCRIPTS_DIR=${SCRIPTS_DIR:-/usr/share/macaroni/live-setup/scripts.d/}
DEF_TIMEZONE=${DEF_TIMEZONE:-"Europe/Rome"}

run_scripts() {
  for i in `ls -1 ${SCRIPTS_DIR}*.sh` ; do
    # Run every function defined of scripts
    echo $i ;

    base=$(basename $i)
    fprefix=$(echo $base | sed -e 's|.sh||g' -e 's|^.*[-]||g')

    source $i

    setup_${fprefix}
  done

  return 0
}


main() {
  run_scripts
}
