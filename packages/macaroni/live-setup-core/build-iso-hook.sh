#!/bin/bash
# Geniso hook called at the of the ISO build process.

set -x
set -e

yqbin=/usr/bin/yq4

setup_anise_config() {
  ${yqbin} '.general.debug = false' /etc/luet/luet.yaml -i
  ${yqbin} '.general.spinner_charset = 39' /etc/luet/luet.yaml -i
  ${yqbin} 'del(.finalizer_envs)' /etc/luet/luet.yaml -i
  ${yqbin} 'del(.general.spinner_ms)' /etc/luet/luet.yaml -i

  # Setup config protect option.
  mkdir -p /etc/luet/config.protect.d || true
  echo "
name: \"etc_conf\"
dirs:
  - \"/etc/\"
" > /etc/luet/config.protect.d/01_etc.yml

  return 0
}

main () {
  setup_anise_config
}

main $@
exit $?
