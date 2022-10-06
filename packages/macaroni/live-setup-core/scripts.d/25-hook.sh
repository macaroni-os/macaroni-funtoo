#!/bin/bash

setup_hook() {
  if [ -n "${HOOKS}" ] ; then
    whip hook ${HOOKS[@]}
  fi
}
