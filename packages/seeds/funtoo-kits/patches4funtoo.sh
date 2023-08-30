#!/bin/bash
# Authors: Daniele Rondina
# Macaroni OS patches for Funtoo

# Fix zziplib to use python3+
rm -rf /var/git/meta-repo/kits/dev-kit/dev-libs/zziplib/
cp -rvf patches/zziplib/ /var/git/meta-repo/kits/dev-kit/dev-libs/

# Permits compilation of qt-webkit with ruby3.1
sed -i -e 's|^USE_RUBY=.*|USE_RUBY="ruby25 ruby26 ruby27 ruby31"|g' \
  /var/git/meta-repo/kits/qt-kit/dev-qt/qtwebkit/qtwebkit-*.ebuild
