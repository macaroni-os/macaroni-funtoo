#!/bin/bash

setup_xorg() {
  mkdir -p /etc/X11/ || true

  eselect opengl set xorg-x11 --use-old
}
