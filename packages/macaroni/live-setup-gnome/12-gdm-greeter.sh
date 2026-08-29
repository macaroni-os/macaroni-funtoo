#!/bin/bash
# Author: Daniele Rondina, geaaru@macaronios.org

setup_gdm_greeter() {
  # Set permission for gdm-greeter user
  mkdir -p /run/gdm || true
  chown gdm:gdm -R /run/gdm
  chmod g+rw -R /run/gdm
}
