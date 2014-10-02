#!/usr/bin/env bash

set -e

SCRIPT_DIR="$(cd $(dirname $0); pwd)"

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

declare -a ALL_APPS
ALL_APPS+=("firefox")
ALL_APPS+=("node.js")
ALL_APPS+=("chrome")
ALL_APPS+=("git")
ALL_APPS+=("vim")
ALL_APPS+=("gpg")
ALL_APPS+=("libreoffice")
ALL_APPS+=("pandoc")
ALL_APPS+=("reprepro")
ALL_APPS+=("firefox")
ALL_APPS+=("firefox")
ALL_APPS+=("firefox")
ALL_APPS+=("firefox")
ALL_APPS+=("firefox")
ALL_APPS+=("firefox")
ALL_APPS+=("firefox")
ALL_APPS+=("firefox")
ALL_APPS+=("firefox")
ALL_APPS+=("firefox")
ALL_APPS+=("firefox")

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

checkInstall()
{
  APPNAME="$1"

  if test "$ALL" = "true"; then
    return 0
  fi

  for APP in ${INSTALL[@]}; do
    if cat "$APPNAME" | grep -iq "^${APP}$"; then
      return 0
    fi
  done

  return 1
}

addRepo()
{
  REPO="$1"
  KEYID="$2"

  if test -n "$KEYID" && ! apt-key finger | sed 's~ ~~g' | grep -qi "Keyfingerprint=${KEYID}"; then
    sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys "${KEYID}"
  fi

  sudo add-apt-repository "${REPO}"
}

echo "Do you wish to add the 1.5 debian proxy? (Y/N)"
read USE_PROXY

if test "${USE_PROXY}" = "Y"; then
  echo "Adding 1.5 proxy"
  addProxyLine "Acquire::Http::Proxy" "http://192.168.1.5:3142"
fi

echo "Assessing app proxy options"

if checkInstall "docker"; then
  # Adding proxy override for docker
  addProxyLine "Acquire::Http::Proxy::get.docker.io" "DIRECT"
fi

echo "Adding debian repositories"

if checkInstall "node.js"; then
  addRepo "ppa:chris-lea/node.js"
fi

if checkInstall "git"; then
  addRepo "ppa:git-core/ppa"
fi

if checkInstall "chrome"; then
  addRepo "deb http://dl.google.com/linux/chrome/deb stable main" "A040830F7FAC5991"
fi

if checkInstall "docker"; then
  addRepo ""
