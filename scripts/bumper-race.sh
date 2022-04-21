#!/bin/bash
# Description: Wrapper script of bumper.sh to commit only packages related
#              to the selected seed.
# Author: Daniele Rondina <geaaru@funtoo.org>

SEED="${SEED:-}"
REPO_DIR=${REPO_DIR:-.}

kits_map="${KITS_MAPFILE:-${REPO_DIR}/portage-converter/kits-specs-map.yaml}"

main() {
  local seed=""
  local i=0

  if [ -z "${SEED}" ] ; then
    echo "Missing SEED variable"
    return 1
  fi

  echo "Bumping packages of the seed ${SEED}..."

  seed=$(yq r ${kits_map} seeds -j | jq ".[] | select(.name==\"${SEED}\")" -r -c)

  if [ -z "${seed}" ] ; then
    echo "Invalid seed selected"
    return 1
  fi

  prefix=$(echo ${seed} | jq .prefix -r)
  nspecs=$(echo ${seed} | jq '.specs | length')

  for ((i=0; i<${nspecs}; i++)) ; do
    file=$(echo ${seed} | jq ".specs[${i}].file" -r)
    dir=$(echo ${seed} | jq ".specs[${i}].dir" -r)

    echo "Bumping package of seed ${SEED} and dir ${dir}..."

    BUMPER_DIR="${REPO_DIR}/${prefix}/${dir}" sh ${REPO_DIR}/scripts/bumper.sh
  done


  return 0
}

main $@
exit $?
