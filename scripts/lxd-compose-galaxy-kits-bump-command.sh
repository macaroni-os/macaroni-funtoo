#!/bin/bash
# Author: Daniele Rondina, geaaru@sabayonlinux.org
# Description: This script permit to generate the
#              lxd-compose command file to generate
#              the current reposcan file or with the
#              override of the commit_sha1 bump new kits.

LCG_KITS_FILE=${LCG_KITS_FILE:-/lxd-compose-galaxy/envs/funtoo/commands/reposcan-funtoo-kits.yml}
MFUNTOO_TREE=${MFUNTOO_TREE:-.}

KITS_PKG=${KITS_PKG:-${MFUNTOO_TREE}/packages/seeds/funtoo-kits/kits-versions/}

kits=$(yq r ${LCG_KITS_FILE} 'envs.envs.kits' -j | jq .[].name -r | sort)
kits_json="$(yq r ${LCG_KITS_FILE} 'envs.envs.kits' -j)"
tmp_file=/tmp/kits-staging.json

# Prepare the new command
tmp_command=/tmp/cmd.yaml
tmp_kits=/tmp/kits.yaml

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

  commit=$(yq r ${KITS_PKG}$k.yml 'commit')

  echo "Kit ${k} using hash ${commit}..."

  yq r ${LCG_KITS_FILE} 'envs.envs.kits' -j  | \
    jq ".[] | select(.name==\"${k}\")" | \
    jq ". |= . + { \"commit_sha1\": \"${commit}\" }" >> ${tmp_file}

done

echo '{ "envs": { "envs": { "kits": [] } } }' | jq '.envs.envs.kits += $inputs' --slurpfile inputs ${tmp_file}  | yq r -P - > ${tmp_kits}

yq m ${tmp_command} ${tmp_kits}
