#!/bin/bash

setup_final() {
  locale-gen

  macaronictl env-update
  source /etc/profile
}
