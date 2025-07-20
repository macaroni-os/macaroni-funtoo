#!/bin/bash
# Authors: Daniele Rondina
# Macaroni OS patches for MARK

# ibus upgraded and available on geaaru-kit. TODO: open a PR to MARK

# xorg-server with wayland support available on geaaru-kit. TODO: open a PR to MARK
# after testing solution.

sed -i -e '/sys-libs\/pam\[elogind\]/d' \
  /var/git/meta-repo/kits/core-gl-kit/x11-base/xorg-server/xorg-server-*.ebuild

# Update libmediaart to fix compilation of rygel
cp -vf patches/libmediaart/* /var/git/meta-repo/kits/gnome-kit/media-libs/libmediaart/
cd /var/git/meta-repo/kits/gnome-kit/media-libs/libmediaart/ && \
ebuild libmediaart-1.9.6-r1.ebuild digest && \
cd -

# dev-python/netaddr (to autogen) 

# Packages missing on Next (but available on 1.4 needed for xfce and other)
# Temporary I will add these packages on geaaru-overlay
# media-libs/vo-aacenc
# media-libs/libbs2b
# media-libs/t1lib
# media-libs/libopenraw
# media-libs/libtiger
# media-vidoe/vcdimager (needed for k3b[vcd])
#
# Deps of media-video/kino packages are missing

# Patch qt5-build.eclass to fix compilation of qdbus package.
# (need rebuild of qtcore and qtdbus)
cp patches/eclass/qt5-build.patch /tmp/ && \
cd /var/git/meta-repo/kits/core-kit/eclass/ && \
patch -p1 < /tmp/qt5-build.patch && \
cd -

# ephoto needs a patch on autogen template. nls use flags is no more available.

# dev-util/ostree to upgrade at release 2023.5 (fix compilation issues) or must be replaced
# by libostree package.

# patch for networkmanager-fortisslvpn

# patch libmemcached to avoid installation of autoconf:1.13

# patch espeak-ng

# patch media-libs/quirc (needed for opencv)
