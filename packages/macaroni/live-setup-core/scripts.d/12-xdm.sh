#!/bin/bash

setup_xdm() {
  if [ -n "$DISPLAYMANAGER" ] ; then
    sed -i -e "s|^DISPLAYMANAGER=.*|DISPLAYMANAGER=\"${DISPLAYMANAGER}\"|g" /etc/conf.d/xdm
  fi
}
