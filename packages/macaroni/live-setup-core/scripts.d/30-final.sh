#!/bin/bash

setup_final() {
  locale-gen

  env-update
  ldconfig
  source /etc/profile
}
