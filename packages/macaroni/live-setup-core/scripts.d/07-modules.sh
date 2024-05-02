#!/bin/bash

setup_modules() {
  # Set fuse kernel modules by default.
  # We need this for flatpak stuff.
  mkdir -p /etc/modules-load.d/ || true
  echo "fuse" > /etc/modules-load.d/fuse.conf

  return 0
}
