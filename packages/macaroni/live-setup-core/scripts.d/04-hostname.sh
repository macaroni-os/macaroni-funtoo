#!/bin/bash

setup_hostname() {
  echo "
127.0.0.1   macaroni-phoenix localhost
::1         macaroni-phoenix localhost
" > /etc/hosts

  echo "macaroni-phoenix" > /etc/hostname
  sed -i -e 's|^hostname=.*|hostname="macaroni-phoenix"|' /etc/conf.d/hostname

}
