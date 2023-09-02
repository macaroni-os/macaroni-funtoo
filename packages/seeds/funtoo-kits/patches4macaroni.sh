#!/bin/bash
# Authors: Daniele Rondina
# Macaroni OS patches not applied on Funtoo because
#          probably are not 

# In the near future I want to follow the old Sabayon way
# about the pinentry package to have pinentry-qt, pinentry-gnome, pinentry-gtk.
sed -i -e 's|^PDEPEND.*|PDEPEND="app-crypt/pinentry"|g' \
  gnome-base/gnome-keyring/gnome-keyring-*.ebuild

# Drop package.mask with elogind use flag for x11-misc/sddm
rm /var/git/meta-repo/kits/core-kit/profiles/funtoo/1.0/linux-gnu/flavor/workstation/package.use.mask
