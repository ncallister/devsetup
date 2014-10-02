#!/bin/bash

set -e
set -x
#trap read debug

if [ $# -lt 2 ]; then
  echo "Usage: makecd.sh <playbook name> <version number>"
	exit
fi

ORIGINAL_DIR=$(pwd)

# UBUNTU_VERSION="12.04.4"
# UBUNTU_DISTNAME="precise"

UBUNTU_VERSION="14.04.1"
UBUNTU_DISTNAME="trusty"

ARCHITECTURE="amd64"
# ARCHITECTURE="i386"

DEBIAN_PROXY="http://192.168.1.5:3142"

UBUNTU_MIRROR="http://au.archive.ubuntu.com/ubuntu"

ANSIBLE_DIR="${WORK_DIR}/Ansible"
IMAGES_DIR="${WORK_DIR}/Images"

ISO_FILE_NAME="ubuntu-${UBUNTU_VERSION}-server-${ARCHITECTURE}"
SOURCE_ISO="${IMAGES_DIR}/${ISO_FILE_NAME}.iso"
MOUNT_DIR="/mnt/tempiso"

PRODUCT="${1}"
VERSION="${2}"

SCRIPT="${ANSIBLE_DIR}/install-iso/scripts/generate-iso.sh"
SCRIPT_DIR="$(dirname $SCRIPT)"
IMAGE_FILES="${IMAGES_DIR}/${ISO_FILE_NAME}"
PLAYBOOK="${ANSIBLE_DIR}/${PRODUCT}-playbook"

OUTPUT_FILE="${IMAGES_DIR}/${PRODUCT}-${VERSION}-u${UBUNTU_VERSION}-${ARCHITECTURE}-b$(date +%Y%m%d-%H%M).iso"

if !(test -d "${PLAYBOOK}")
	then
	echo "Invalid product specified, no such directory: ${PLAYBOOK}"
	exit
fi

if [ -d "$IMAGE_FILES" ]
	then
	rm -rf "$IMAGE_FILES"
fi

if test -d "${MOUNT_DIR}"; then
  umount "${MOUNT_DIR}"
else
  mkdir "$MOUNT_DIR"
fi

mount -o loop "$SOURCE_ISO" "$MOUNT_DIR"
mkdir "$IMAGE_FILES"
cp -R -T "$MOUNT_DIR" "$IMAGE_FILES"
umount "$MOUNT_DIR"
rmdir "$MOUNT_DIR"

pushd "$SCRIPT_DIR"

CONFIG=()
CONFIG+=("--out" "$OUTPUT_FILE")
CONFIG+=("--image" "$IMAGE_FILES")
CONFIG+=("--playbook" "$PLAYBOOK")
CONFIG+=("--dist" "$UBUNTU_DISTNAME")
CONFIG+=("--arch" "$ARCHITECTURE")
if test -n "$DEBIAN_PROXY"; then
  CONFIG+=("--deb-proxy" "$DEBIAN_PROXY")
fi
if test -n "$UBUNTU_MIRROR"; then
  CONFIG+=("--ubuntu-mirror" "$UBUNTU_MIRROR")
fi
CONFIG+=("--debug")

$SCRIPT ${CONFIG[@]}

rm -rf "$IMAGE_FILES"

popd
