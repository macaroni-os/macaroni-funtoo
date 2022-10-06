#!/bin/bash

setup_macaroni() {
  # Create root and macaroni user
  entities merge -s /var/lib/macaroni/entities -a
  # user root is already present (created by virtual-entities/base)
  # In this case `entities merge` command doesn't replace the password.
  # I need use apply command.
  entities apply -f /etc/shadow /var/lib/macaroni/entities/entity_shadow_root.yaml

  # Temporary fix until entities will handle this
  mkdir -p /home/
  cp -rvf /etc/skel/ /home/macaroni/
  chown macaroni:users -R /home/macaroni

  eval 'mkdir -p /etc/sudoers.d || true'
  echo "macaroni ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/99-macaroni

  # TODO: check if this must be executed after vboxguest.vboxguest_setup
  #       hook.
  entities merge -s /var/lib/macaroni/entities-macaroni-groups -a

  return 0
}
