#!/bin/bash

setup_hostname() {
  echo "
127.0.0.1   macaroni-funtoo localhost
::1         macaroni-funtoo localhost
" > /etc/hosts

  echo "macaroni-funtoo" > /etc/hostname
  sed -i -e 's|^hostname=.*|hostname="macaroni-funtoo"|' /etc/conf.d/hostname

}
