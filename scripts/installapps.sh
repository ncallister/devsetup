#!/usr/bin/env bash

set -e

SCRIPT_DIR="$(cd $(dirname $0); pwd)"

declare -A ALL_APPS
declare -a INSTALL_APPS

declare -a PARAMETERS

# -a --all
ALL=""
declare -A DEF_ALL=(["VARIABLE"]="ALL" ["LONG"]="all" ["SHORT"]="a" ["TAKES_VALUE"]="false" ["REQUIRED"]="false")
PARAMETERS+=("ALL")

# -i --install
declare -a INSTALL
declare -A DEF_INSTALL=(["VARIABLE"]="INSTALL" ["LONG"]="install" ["SHORT"]="i" ["TAKES_VALUE"]="true" ["REQUIRED"]="false" ["LIST"]="true")
PARAMETERS+=("INSTALL")

. "${SCRIPT_DIR}/processparams.sh"

. "${SCRIPT_DIR}/appdata.sh"

# Mark apps to be installed
if test "$ALL" = "true"; then
  INSTALL_APPS=(ALL_APPS[@])
  echo "Installing all apps"
else
  for APP in ${INSTALL[@]}; do
    if test -n "${ALL_APPS[${APP}]}"; then
      INSTALL_APPS+=("${ALL_APPS[${APP}]}")
      echo "App \"${APP}\" marked for installation"
    else
      echo "App \"${APP}\" unknown, will not be installed"
    fi
  done
fi

addProxyLine()
{
  KEY="$1"
  VALUE="$1"

  if grep -q -i "^${KEY}[ \t]" /etc/apt/apt.conf.d/01proxy; then
    sed "s~^${KEY}[ \t][^\n]*\n~${KEY} \"${VALUE}\"\n" </etc/apt/apt.conf.d/01proxy >/tmp/01proxy
    sudo mv -f /tmp/01proxy /etc/apt/apt.conf.d/01proxy
  else
    echo "${KEY} \"${VALUE}\"" >> /etc/apt/apt.conf.d/01proxy
  fi
}

echo "Do you wish to add the 1.5 debian proxy? (Y/N)"
read USE_PROXY

if test "${USE_PROXY}" = "Y"; then
  echo "Adding 1.5 proxy"
  addProxyLine "Acquire::Http::Proxy" "http://192.168.1.5:3142"
fi

echo "Assessing app proxy options"

for APP in ${INSTALL_APPS[@]}; do
  eval "APP_DATA=${INSTALL_APPS[${APP}]}"

  if test -n "${APP_DATA["proxy-key"]}" && test -n "${APP_DATA["proxy-value"]}"; then
    echo "Adding proxy line for application \"${APP_DATA["name"]}\""
    addProxyLine "${APP_DATA["proxy-key"]}" "${APP_DATA["proxy-value"]}"
  fi
done

echo "Assessing required debian repositories"

for APP in ${INSTALL_APPS[@]}; do
  eval "APP_DATA=${INSTALL_APPS[${APP}]}"

  if test -n "${APP_DATA["repo"]}"; then
    if test -n "${APP_DATA["repo-key"]}" && \
      ! apt-key finger | sed 's~ ~~g' | grep -i "Keyfingerprint=${APP_DATA["repo-key"]}"; then
      sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys "${APP_DATA["repo-key"]}"
    fi
    echo "Adding repository \"${APP_DATA["repo"]}\" for application \"${APP_DATA["name"]}\""
    sudo add-apt-repository "${APP_DATA["repo"]}"
  fi
done

echo "Updating debian system"

sudo apt-get clean
sudo apt-get update
sudo apt-get upgrade

echo "Installing application packages"

for APP in ${INSTALL_APPS[@]}; do
  eval "APP_DATA=${INSTALL_APPS[${APP}]}"

  if test -n "${APP_DATA["package"]}"; then
    if dpkg --status "${APP_DATA["package"]}"; then
      echo "Package \"${APP_DATA["package"]}\" for application \"${APP_DATA["name"]}\" is already installed"
    else
      echo "Installing package \"${APP_DATA["package"]}\" for application \"${APP_DATA["name"]}\""
      sudo apt-get install "${APP_DATA["package"]}"
    fi
  fi
done
