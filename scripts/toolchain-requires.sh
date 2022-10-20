#!/bin/bash

[ "$DEBUG" = true ] && set -x 

TARGET_PKG=${TARGET_PKG:-packages/toolchain/extra-dev}
SOURCE_PKGS_DIR=${SOURCE_PKGS_DIR:-packages/atoms-extra/dev}

packages=$(luet-build tree pkglist -t $SOURCE_PKGS_DIR)

definition_file=${TARGET_PKG}/definition.yaml

# Delete current requires
yq d ${definition_file} "requires" -i

p=0
for i in ${packages};
do
  name=$(pkgs-checker pkg info $i --json | jq '.name' -r)
  cat=$(pkgs-checker pkg info $i --json | jq '.category' -r)

  echo "Adding ${cat}/${name} ($i)"

  yq w -i ${definition_file} "requires[$p].name" "${name}"
  yq w -i ${definition_file} "requires[$p].category" "${cat}"
  yq w -i ${definition_file} "requires[$p].version" ">=0"

  p=$((p+1))
done
