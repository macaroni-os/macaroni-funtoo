#!/bin/bash

polkit_setup() {
  if [ ! -e /var/lib/polkit-1 ] ; then
    mkdir -p /var/lib/polkit-1
  fi

  chmod 0700 "${EROOT}"/{etc,usr/share}/polkit-1/rules.d
  chown -R polkitd:root "${EROOT}"/{etc,usr/share}/polkit-1/rules.d
  chown -R polkitd:polkitd "${EROOT}"/var/lib/polkit-1
}
