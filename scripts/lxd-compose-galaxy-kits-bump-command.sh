#!/bin/bash
# Author: Daniele Rondina, geaaru@funtoo.org
# Description: This script permit to generate the
#              lxd-compose command file to generate
#              the current reposcan file or with the
#              override of the commit_sha1 bump new kits.

LCG_KITS_FILE=${LCG_KITS_FILE:-/lxd-compose-galaxy/envs/funtoo/commands/reposcan-funtoo-next-kits.yml}
LCG_CMD_FILE=${LCG_CMD_FILE:-/tmp/reposcan.yml}
MFUNTOO_TREE=${MFUNTOO_TREE:-.}
KITS_2UPGRADE="${KITS_2UPGRADE:-}"

KITS_PKG=${KITS_PKG:-${MFUNTOO_TREE}/packages/seeds/funtoo-kits/kits-versions/}

kits=$(yq r ${LCG_KITS_FILE} 'envs.envs.kits' -j | jq .[].name -r)
kits_json="$(yq r ${LCG_KITS_FILE} 'envs.envs.kits' -j)"
tmp_file=/tmp/kits-staging.json

# Prepare the new command
tmp_command=/tmp/cmd.yaml
tmp_kits=/tmp/kits.yaml

elementIn () {
  for e in $2; do [[ "$e" == "$1" ]] && return 0; done
  return 1
}

rm ${tmp_file} 2>/dev/null || true
rm ${tmp_command} 2>/dev/null || true
rm ${tmp_kits} 2>/dev/null || true

yq r ${LCG_KITS_FILE} > ${tmp_command}
yq d ${tmp_command} 'envs.envs.kits' -i

for k in ${kits} ; do
  if [ ! -e ${KITS_PKG}$k.yml ] ; then
    echo "Kit file $k.yml not found. Using kits ASIS."
    yq r ${LCG_KITS_FILE} 'envs.envs.kits' -j  | \
      jq ".[] | select(.name==\"${k}\")" >> ${tmp_file}
    continue
  fi

  commit=""

  if [ -n "${KITS_2UPGRADE}" ] ; then
    if ! elementIn "${k}" "${KITS_2UPGRADE}" ; then
      commit=$(yq r ${KITS_PKG}$k.yml 'commit')
    fi
  else
    commit=$(yq r ${KITS_PKG}$k.yml 'commit')
  fi

  if [ -n "${commit}" ] ; then
    echo "Kit ${k} using hash ${commit}..."

    yq r ${LCG_KITS_FILE} 'envs.envs.kits' -j  | \
      jq ".[] | select(.name==\"${k}\")" | \
      jq ". |= . + { \"commit_sha1\": \"${commit}\" }" >> ${tmp_file}
  else
    branch=$(yq r ${LCG_KITS_FILE} 'envs.envs.kits' -j | jq ".[] | select(.name==\"${k}\")" | jq .branch -r)
    echo "Kit ${k} updating branch ${branch}..."
    yq r ${LCG_KITS_FILE} 'envs.envs.kits' -j  | \
      jq ".[] | select(.name==\"${k}\")" >> ${tmp_file}
  fi

done

echo '{ "envs": { "envs": { "kits": [] } } }' | jq '.envs.envs.kits += $inputs' --slurpfile inputs ${tmp_file}  | yq r -P - > ${tmp_kits}

echo "Creating lxd-compose command on file ${LCG_CMD_FILE}..."
yq m ${tmp_command} ${tmp_kits} > ${LCG_CMD_FILE}
