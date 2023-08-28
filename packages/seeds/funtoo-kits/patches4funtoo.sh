#!/bin/bash
# Authors: Daniele Rondina
# Macaroni OS patches for Funtoo

# Fix zziplib to use python3+
rm -rf /var/git/meta-repo/kits/dev-kit/zziplib/
cp -rvf patches/zziplib/ /var/git/meta-repo/kits/dev-kit/


