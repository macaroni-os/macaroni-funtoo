#!/bin/bash
# Author: Daniele Rondina, geaaru@sabayonlinux.org

# Example:
# $> sh scripts/generate-layer-provides.sh packages/funtoo-base-gnome/

# Path of the package from root
PACKAGE=${PACKAGE:-$1}

ROOT_DIR=$(dirname ${BASH_SOURCE[0]})/..
deffile=${ROOT_DIR}/$PACKAGE/definition.yaml

emerge_packages=$(yq r $deffile 'labels."emerge.packages"')

p=0
for i in ${emerge_packages} ; do
  cat=$(pkgs-checker pkg info ${i} --json | jq '.category' -r)
  name=$(pkgs-checker pkg info ${i} --json | jq '.name' -r)
  slot=$(pkgs-checker pkg info ${i} --json | jq '.slot' -r)

  if [ "${slot}" == "null" ] ; then
    slot="0"
  fi

  if [ "${slot}" != "0" ] ; then
    slot=$(echo "${slot}" | sed 's:/.*::g')
    cat="${cat}-${slot}"
  fi

  echo "Adding ${cat}/${name} ($i)"

  yq w -i $deffile "provides[$p].name" "${name}"
  yq w -i $deffile "provides[$p].category" "${cat}"
  yq w -i $deffile "provides[$p].version" ">=0"

  p=$((p+1))
done
