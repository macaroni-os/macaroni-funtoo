#!/bin/bash
# Authors: Daniele Rondina
# Macaroni OS patches for Funtoo

# Fix zziplib to use python3+
rm -rf /var/git/meta-repo/kits/dev-kit/dev-libs/zziplib/
cp -rvf patches/zziplib/ /var/git/meta-repo/kits/dev-kit/dev-libs/

# Permits compilation of qt-webkit with ruby3.1
sed -i -e 's|^USE_RUBY=.*|USE_RUBY="ruby25 ruby26 ruby27 ruby31"|g' \
  /var/git/meta-repo/kits/qt-kit/dev-qt/qtwebkit/qtwebkit-*.ebuild

# ibus upgraded and available on geaaru-kit. TODO: open a PR to Funtoo

# xorg-server with wayland support available on geaaru-kit. TODO: open a PR to Funtoo
# after testing solution.

# Fix wrong DEPEND on source-hightlight
sed -i -e 's|>=dev-libs/boost-1.62.0\:=\[threads\]|dev-libs/boost|g' \
  /var/git/meta-repo/kits/dev-kit/dev-util/source-highlight/source-highlight-*.ebuild

# Fix typo on x11-base/xorg-drivers ebuild
sed -i -e 's|xf86-video-vboxvideo|xf86-video-vbox|g' \
  /var/git/meta-repo/kits/core-gl-kit/x11-base/xorg-drivers/xorg-drivers-*.ebuild

# Permit using vala 0.54
sed -i -e 's|0.50|0.54|g' \
  /var/git/meta-repo/kits/core-kit/eclass/vala.eclass

# Drop pam/elogind dependencies cross referencies
sed -i -e 's|elogind? ( .* )||g' -e 's|elogind||g' \
  /var/git/meta-repo/kits/core-kit/sys-libs/pam/pam-*.ebuild

sed -i -e '/sys-libs\/pam\[elogind\]/d' \
  /var/git/meta-repo/kits/core-gl-kit/x11-base/xorg-server/xorg-server-*.ebuild

# Using vala 0.54 seems break media-video/cheese that requires
# a new release
cp -vf patches/cheese/* /var/git/meta-repo/kits/gnome-kit/media-video/cheese/
cd /var/git/meta-repo/kits/gnome-kit/media-video/cheese/
ebuild cheese-44.1.ebuild digest
cd -

