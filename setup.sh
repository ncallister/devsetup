#!/usr/bin/env bash

set -e
set -x

BASE_DIR="$(cd "$(dirname $0)"; pwd)"
HOME_DIR="$(cd ~; pwd)"

UNINSTALL="false"
if test "$1" = "--uninstall"; then
  UNINSTALL="true"
fi

link_file()
{
  if test "$UNINSTALL" = "true"; then
    unlink_file "$1" "$2"
    return $?
  fi

  FILE="$BASE_DIR/$1"
  DESTINATION="$HOME_DIR/$2"

  mkdir -p "$(dirname "$DESTINATION")"

  if test -f "$DESTINATION"; then
    CONFIRM=" "

    if diff "$FILE" "$DESTINATION"; then
      CONFIRM="Y"
    fi

    while test "$CONFIRM" != "Y" && test "$CONFIRM" != "N"; do
      echo "The existing config file at \"$DESTINATION\" differs. Are you sure you wish to replace it? (Y/N)"
      read CONFIRM
    done

    if test "$CONFIRM" = "Y"; then
      rm -f "$DESTINATION"
    fi
  fi

  if ! test -f "$DESTINATION"; then
    ln -s "$FILE" "$DESTINATION"
  fi
}

unlink_file()
{
  FILE="$BASE_DIR/$1"
  DESTINATION="$HOME_DIR/$2"

  if file "${DESTINATION}" | grep "symbolic link to \`${FILE}'"; then
    echo "Unlinking and restoring ${DESTINATION}"
    rm -f "${DESTINATION}";
    cp "${FILE}" "${DESTINATION}"
  else
    echo "File \"${DESTINATION}\" is not a symlink to \"${FILE}\""
  fi
}

for SETUP in $(ls $BASE_DIR/*/setup.sh); do
  . $SETUP
done
