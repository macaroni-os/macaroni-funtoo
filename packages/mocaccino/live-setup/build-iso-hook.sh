#!/bin/bash
# Geniso hook called at the of the ISO build process.

set -x
set -e

setup_luet_config() {
  yq w /etc/luet/luet.yaml 'general.debug' "false" -i
  yq d /etc/luet/luet.yaml 'finalizer_envs' -i
  yq w /etc/luet/luet.yaml 'general.spinner_charset' "39" -i
  yq d /etc/luet/luet.yaml 'general.spinner_ms' -i

  return 0
}

main () {
  setup_luet_config
}

main $@
exit $?
