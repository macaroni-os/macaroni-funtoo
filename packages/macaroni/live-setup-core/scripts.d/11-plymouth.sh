#!/bin/bash

setup_plymouth() {
  if [ -n "${PLYMOUTH_THEME}" ] ; then
    plymouth-set-default-theme "${PLYMOUTH_THEME}"
  fi
  return 0
}
