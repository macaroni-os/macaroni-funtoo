#!/bin/bash
# Author: Daniele Rondina, geaaru@sabayonlinux.org

openrc_init_runlevels() {
  source /lib/rc/sh/functions.sh

  for r in sysinit boot shutdown default nonetwork; do
    if [ ! -e ${EROOT}/etc/runlevels/$r ]; then
      install -d ${EROOT}/etc/runlevels/$r
      # install missing scripts
    fi
    for sc in $(cd ${EROOT}/usr/share/openrc/runlevels/$r; ls); do
      if [ ! -L ${EROOT}/etc/runlevels/$r/$sc ]; then
        einfo "Missing $r/$sc script, installing..."
        cp -a ${EROOT}/usr/share/openrc/runlevels/$r/$sc ${EROOT}/etc/runlevels/$r/$sc
      fi
    done
    # warn about extra scripts
    for sc in $(cd ${EROOT}/etc/runlevels/$r; ls); do
      if [ "$sc" == "netif.lo" ]; then
        einfo "Removing old initscript netif.lo."
        rm ${EROOT}/etc/runlevels/$r/$sc
      fi
      if [ ! -L ${EROOT}/usr/share/openrc/runlevels/$r/$sc ]; then
        ewarn "Extra script $r/$sc found, possibly from other ebuild."
      fi
    done
  done


}
