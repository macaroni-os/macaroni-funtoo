#!/bin/bash
# Author: Daniele Rondina, geaaru@sabayonlinux.org

gtk_update_icons() {
  # Fix gnome icons caches
  rm -f /usr/share/icons/hicolor/icon-theme.cache
  gtk-update-icon-cache -f /usr/share/icons/*
}

glib_update_schemas() {
  glib-compile-schemas /usr/share/glib-2.0/schemas
}
