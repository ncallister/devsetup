#!/bin/bash

set -e
set -x

ATOM_DIR="$TEMP_DIR/atom"

if ! test -d "$ATOM_DIR"; then
  git clone https://github.com/atom/atom "$ATOM_DIR"
fi

pushd "$ATOM_DIR"
git fetch -v --all --prune

LATEST_GIT_TAG=$(git describe --tags $(git rev-list --tags --max-count=1))
LATEST_VERSION="${LATEST_GIT_TAG#v}"
INSTALLED_VERSION=$(atom --version)
INSTALLED_VERSION="${INSTALLED_VERSION%%-*}"

if test "$LATEST_VERSION" != "$INSTALLED_VERSION"; then
    git checkout "$LATEST_GIT_TAG"
    script/build
    sudo script/grunt install
fi

popd
