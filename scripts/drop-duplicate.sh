#!/bin/bash

dir=$1

atomdir=$(echo $dir | sed -e 's|/| |g' | awk '{ print $3 }')

dry_run=${DRYRUN:-0}
duplicate_pkgs=0
echo "Analyze duplicate for atoms dir ${atomdir}..."

for i in $(find ${dir} -name definition.yaml) ; do
  package=$(grep emerge.package $i | awk '{ print $2 }')
  ndefs=$(grep "emerge.packages: $package$" -r packages/* -r -l | wc -l)
  defs=$(grep "emerge.packages: $package$" -r packages/* -r -l)

  [ -n "$DEBUG" ] && echo "For package ${package} found ${ndefs} definition.yaml files."
  if [ "$ndefs" = 1 ] ; then
    continue
  fi

  for f in ${defs} ; do
    ad=$(echo $f | sed -e 's|/| |g' | awk '{ print $3 }')

    if [ "$ad" != "${atomdir}" ] ; then
      echo "Found duplicate for package $package on atoms dir ${ad}..."
      dir=$(dirname $f)

      let duplicate_pkgs++

      if [ ${dry_run} -eq 0 ] ; then
        [ -n "${DEBUG}" ] && echo "Removing $dir..."
        git rm -r ${dir}
      fi
    fi

  done

done

echo "Found ${duplicate_pkgs} duplicates."
