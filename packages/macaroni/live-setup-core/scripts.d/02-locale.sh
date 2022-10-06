#!/bin/bash

setup_locale() {
  for word in ${CMDLINE}; do
    case ${word} in
      locale=*)
        lang_toset="${word/*=}"
        ;;
      LANG=*)
        lang_toset="${word/*=}"
        ;;
      lang=*)
        lang_toset="${word/*=}"
        ;;
    esac
  done
  if [ -n "${lang_toset}" ]; then
    local files=(
      "/etc/env.d/02locale"
      "/etc/locale.conf"
    )

    for path in "${files[@]}"; do
      if [ -e "$path" ]; then
        sed -i "s/^LC_ALL=.*/LC_ALL=${lang_toset}.UTF-8/g" \
          "${path}"
        sed -i "s/^LANG=.*/LANG=${lang_toset}.UTF-8/g" "${path}"
        sed -i "s/^LANGUAGE=.*/LANGUAGE=${lang_toset}.UTF-8/g" \
          "${path}"
      else
        echo "LC_ALL=${lang_toset}.UTF-8" > "${path}"
        echo "LANG=${lang_toset}.UTF-8" >> "${path}"
        echo "LANGUAGE=${lang_toset}.UTF-8" >> "${path}"
      fi
    done

    sed -i "s/^export LC_ALL=.*/export LC_ALL=${lang_toset}.UTF-8/g" \
      "/etc/profile.env"
    sed -i "s/^export LANG=.*/export LANG=${lang_toset}.UTF-8/g" \
      "/etc/profile.env"
    sed -i "s/^export LANGUAGE=.*/export LANGUAGE=${lang_toset}.UTF-8/g" \
      "/etc/profile.env"
  fi
}
