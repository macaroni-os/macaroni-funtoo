#!/bin/bash

repo_dir=$(dirname ${BASH_SOURCE[0]})/..

for f in $(find ${repo_dir} -name definition.yaml) ; do

  with_label_len=$(yq4 e '.labels."original.package.name" | length' $f)
  if [ "${with_label_len}" != "0" ] ; then
    pkg=$(yq4 e '.labels."original.package.name"' $f)
    echo ${pkg}
  fi
done
