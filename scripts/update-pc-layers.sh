#!/bin/bash
#
# Author: Daniele Rondina, geaaru@funtoo.org
# Description: Update all portage-converter layers file defined
#              on kits-specs-map.yaml files.

REPO_DIR=$(dirname ${BASH_SOURCE[0]})/..

KITS_SPECS_MAP=${KITS_SPECS_MAP:-${REPO_DIR}/portage-converter/kits-specs-map.yaml}

nseeds=$(yq4 e '.seeds | length' ${KITS_SPECS_MAP})

for ((i=0; i<${nseeds}; i++)); do
  LAYER_NAME=$(yq4 e ".seeds[${i}].name" ${KITS_SPECS_MAP})
  export LAYER_NAME
  sh scripts/create-pc-layer.sh || {
    echo "Something goes wrong for layer ${LAYER_NAME}..."
  }
done
