#!/bin/bash

setup_xorg() {
  mkdir -p /etc/X11/ || true

  setup_default_xsession
}

setup_default_xsession() {
  if [ -n "${DEFAULT_XSESSION}" ] ; then
    local sess="${DEFAULT_XSESSION}"
    echo "[Desktop]" > /etc/skel/.dmrc
    echo "Session=${sess}" >> /etc/skel/.dmrc
    rm -vf /usr/share/xsessions/default.desktop || true
    ln -sf "${sess}.desktop" /usr/share/xsessions/default.desktop
  fi
}

