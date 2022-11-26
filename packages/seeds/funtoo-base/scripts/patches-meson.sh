#!/bin/bash

cp -rvf patches/babl/files /var/git/meta-repo/kits/gnome-kit/media-libs/babl/ && \
cp patches/babl/babl-0.1.78.ebuild /var/git/meta-repo/kits/gnome-kit/media-libs/babl/babl-0.1.78.ebuild

cp -rvf patches/meson/meson-0.63.1.ebuild /var/git/meta-repo/kits/core-kit/dev-util/meson/ && \
cd /var/git/meta-repo/kits/core-kit/dev-util/meson/ && \
rm Manifest && \
ebuild meson-0.63.1.ebuild digest && cd -

cp -rvf patches/gedit/files /var/git/meta-repo/kits/gnome-kit/app-editors/gedit/ && \
cp patches/gedit/gedit-3.36.2.ebuild /var/git/meta-repo/kits/gnome-kit/app-editors/gedit/gedit-3.36.2.ebuild

cp -rvf patches/eog/files /var/git/meta-repo/kits/gnome-kit/media-gfx/eog/ && \
cp patches/eog/eog-3.36.3.ebuild /var/git/meta-repo/kits/gnome-kit/media-gfx/eog/eog-3.36.3.ebuild

cp -vf patches/gtk-vnc/gtk-vnc-1.3.1.ebuild /var/git/meta-repo/kits/gnome-kit/net-libs/gtk-vnc && \
cd /var/git/meta-repo/kits/gnome-kit/net-libs/gtk-vnc && \
rm Manifest && ebuild gtk-vnc-1.3.1.ebuild digest && cd -

cp -rvf patches/totem/files /var/git/meta-repo/kits/gnome-kit/media-video/totem/ && \
cp -vf patches/totem/totem-3.34.1.ebuild /var/git/meta-repo/kits/gnome-kit/media-video/totem

cp -rvf patches/gnome-shell/files /var/git/meta-repo/kits/gnome-kit/gnome-base/gnome-shell && \
cp -vf patches/gnome-shell/gnome-shell-3.36.7-r1.ebuild /var/git/meta-repo/kits/gnome-kit/gnome-base/gnome-shell/

cp -rvf patches/gnome-tweaks/files /var/git/meta-repo/kits/gnome-kit/gnome-extra/gnome-tweaks && \
cp -vf patches/gnome-tweaks/gnome-tweaks-3.34.0-r1.ebuild /var/git/meta-repo/kits/gnome-kit/gnome-extra/gnome-tweaks/

cp -rvf patches/gnome-music/files /var/git/meta-repo/kits/gnome-kit/media-sound/gnome-music/ && \
cp -vf patches/gnome-music/gnome-music-3.36.6.ebuild /var/git/meta-repo/kits/gnome-kit/media-sound/gnome-music/

# Fix dconf
sed -i -e 's|-Denable-man=true|$(meson_use man)|g' -e 's|^IUSE=.*|IUSE="+man"|g' /var/git/meta-repo/kits/gnome-kit/gnome-base/dconf/dconf-0.36.0.ebuild

# Fix gnome-session
cp -rvf patches/gnome-session/* /var/git/meta-repo/kits/gnome-kit/gnome-base/gnome-session/

# Fix gnome-weather
cp -rvf patches/gnome-weather/* /var/git/meta-repo/kits/gnome-kit/gnome-extra/gnome-weather/

# Fix graphene
sed -i -e '/-Dbenchmarks=false/d' /var/git/meta-repo/kits/media-kit/media-libs/graphene/graphene-1.10.0.ebuild

# Fix sys-apps/accountsservice
cp -rvf patches/accountsservice/* /var/git/meta-repo/kits/gnome-kit/sys-apps/accountsservice/

# Fix gnome-bluetooth
cp -rvf patches/gnome-bluetooth/* /var/git/meta-repo/kits/gnome-kit/net-wireless/gnome-bluetooth/

# Fix gvfs
cp -rvf patches/gvfs/* /var/git/meta-repo/kits/gnome-kit/gnome-base/gvfs/

# Fix gnome-backgrounds
cp -rvf patches/gnome-backgrounds/* /var/git/meta-repo/kits/gnome-kit/x11-themes/gnome-backgrounds/

# Update gstreams-meson.eclass
cp -vf patches/eclass/* /var/git/meta-repo/kits/core-kit/eclass/

# dconf-editor
cp -rvf patches/dconf-editor/* /var/git/meta-repo/kits/gnome-kit/gnome-base/dconf-editor/

# gnome-dictionary
cp -rvf patches/gnome-dictionary/* /var/git/meta-repo/kits/gnome-kit/app-dicts/gnome-dictionary/

# gnome-font-viewer
cp -rvf patches/gnome-font-viewer/* /var/git/meta-repo/kits/gnome-kit/media-gfx/gnome-font-viewer/

# nautilus-sendto
cp -rvf patches/nautilus-sendto/* /var/git/meta-repo/kits/gnome-kit/gnome-extra/nautilus-sendto/

# tali
cp -rvf patches/tali/* /var/git/meta-repo/kits/gnome-kit/games-board/tali/

# hitori
cp -rvf patches/hitori/* /var/git/meta-repo/kits/gnome-kit/games-puzzle/hitori/

# gnome-characters
cp -rvf patches/gnome-characters/* /var/git/meta-repo/kits/gnome-kit/gnome-extra/gnome-characters/

# gnome-screenshot (todo: fix gnome3_icon_cache_update)
cp -rvf patches/gnome-screenshot/* /var/git/meta-repo/kits/gnome-kit/media-gfx/gnome-screenshot/

# gnome-sound-recorder
cp -rvf patches/gnome-sound-recorder/* /var/git/meta-repo/kits/gnome-kit/media-sound/gnome-sound-recorder/

# gnome-mahjongg
cp -rvf patches/gnome-mahjongg/* /var/git/meta-repo/kits/gnome-kit/games-board/gnome-mahjongg/
# gnome-mines
cp -rvf patches/gnome-mines/* /var/git/meta-repo/kits/gnome-kit/games-board/gnome-mines/
# gnome-tetravex
cp -rvf patches/gnome-tetravex/* /var/git/meta-repo/kits/gnome-kit/games-puzzle/gnome-tetravex/
# nautilus
cp -rvf patches/nautilus/* /var/git/meta-repo/kits/gnome-kit/gnome-base/nautilus/
# gst-plugins-vaapi
cp -rvf patches/gst-plugins-vaapi/* /var/git/meta-repo/kits/media-kit/media-plugins/gst-plugins-vaapi/
# Add patch to seahorse for gnupg check
cp -rvf patches/seahorse/* /var/git/meta-repo/kits/gnome-kit/app-crypt/seahorse/
# sudoku
cp -rvf patches/sudoku/* /var/git/meta-repo/kits/gnome-kit/games-puzzle/gnome-sudoku/
# gnome-todo
cp -rvf patches/gnome-todo/* /var/git/meta-repo/kits/gnome-kit/gnome-extra/gnome-todo/
# gnome-calendar
cp -rvf patches/gnome-calendar/* /var/git/meta-repo/kits/gnome-kit/gnome-extra/gnome-calendar/
# gnome-user-share
cp -rvf patches/gnome-user-share/* /var/git/meta-repo/kits/gnome-kit/gnome-extra/gnome-user-share/
# bijiben
cp -rvf patches/bijiben/* /var/git/meta-repo/kits/gnome-kit/app-misc/bijiben/
# gnome-settings-daemon
cp -rvf patches/gnome-settings-daemon/* /var/git/meta-repo/kits/gnome-kit/gnome-base/gnome-settings-daemon/
# gnome-disk-utility
cp -rvf patches/gnome-disk-utility/* /var/git/meta-repo/kits/gnome-kit/sys-apps/gnome-disk-utility/
# cheese
cp -rvf patches/cheese/* /var/git/meta-repo/kits/gnome-kit/media-video/cheese/
# gnome2048
cp -rvf patches/gnome2048/* /var/git/meta-repo/kits/gnome-kit/games-puzzle/gnome2048/
# gnome-maps
cp -rvf patches/gnome-maps/* /var/git/meta-repo/kits/gnome-kit/sci-geosciences/gnome-maps/

sed -i -e 's|enable-introspection|introspection|g' /var/git/meta-repo/kits/gnome-kit/app-text/libgepub/libgepub-0.6.0.ebuild
