#!/bin/bash
# Author: Daniele Rondina, geaaru@funtoo.org

setup_gnome_shell_extentions() {

  if [ -n "${GNOME_SHELL_EXTS}" ] ; then
    for i in ${GNOME_SHELL_EXTS[@]} ; do
      # Retrieve the extension id
      gsid=$(eselect gnome-shell-extensions list  | grep ${i} | awk '{ print $1 }' | sed -e 's|\[||g' -e 's|\]||g')

      eselect gnome-shell-extensions enable ${gsid}
    done

    eselect gnome-shell-extensions list
  fi

}
