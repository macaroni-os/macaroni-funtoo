#!/bin/bash


setup_all_fonts() {
  local i=""

  for i in $(ls ${EROOT}/usr/share/fonts/) ; do
    if [ $i != "encoding" ] ; then
      FONT_DIR=$i
      create_fonts_scale
      create_fonts_dir
    fi
  done
}

# Create fonts.scale file, used by the old server-side fonts subsystem.
create_fonts_scale() {
  if [[ ${FONT_DIR} != Speedo && ${FONT_DIR} != CID ]]; then
    echo "Generating fonts.scale for ${FONT_DIR}"
    mkfontscale \
      -a "${EROOT}/usr/share/fonts/encodings/encodings.dir" \
      -- "${EROOT}/usr/share/fonts/${FONT_DIR}"
  fi
}


# Create fonts.dir file, used by the old server-side fonts subsystem.
create_fonts_dir() {
  echo "Generating fonts.dir for ${FONT_DIR}"
  mkfontdir \
    -e "${EROOT}"/usr/share/fonts/encodings \
    -e "${EROOT}"/usr/share/fonts/encodings/large \
    -- "${EROOT}/usr/share/fonts/${FONT_DIR}"
}

