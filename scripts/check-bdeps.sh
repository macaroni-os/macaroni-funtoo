#!/bin/bash
# Author: Daniele Rondina, geaaru@macaronios.org
# Description: Check if there packages without bdeps or with more or
#              one requires.

dir=$1

if [ -z "${dir}" ] ; then
  echo "Use check-bdeps.sh <packages/atoms/dir>"
  exit 1
fi

atomdir=$(echo $dir | sed -e 's|/| |g' | awk '{ print $3 }')
dry_run=${DRYRUN:-0}
echo "Analyze atoms dir ${atomdir}..."

err=0

for i in $(find ${dir} -name build.yaml) ; do
  bdir=$(dirname ${i})
  def=${bdir}/definition.yaml
  nreqs=$(yq4 e '.requires | length' $i)
  package=$(grep emerge.package $def | awk '{ print $2 }')
  if [[ "${nreqs}" -eq 0 || "${nreqs}" -gt 1 ]] ; then
    echo "For package ${package} ${nreqs} dependencies ($i)."
    let err++
  fi

done

echo "Found ${err} issues."
