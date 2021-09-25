#!/bin/bash
# Author: Daniele Rondina, geaaru@sabayonlinux.org

mime_update_db() {
  update-mime-database /usr/share/mime
  gdk-pixbuf-query-loaders --update-cache
}
