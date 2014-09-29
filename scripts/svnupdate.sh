#!/bin/bash

# set -e
# set -x
# trap read debug

for DIR in $(find "$WORK_DIR" -maxdepth 5 -name ".svn"); do
    #svn upgrade "$(dirname "${DIR}")"
    svn update "$(dirname "${DIR}")"
done
