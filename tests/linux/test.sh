#!/bin/sh

set -euo pipefail

if [ -z "${DISTRO}" ]; then
  echo "Please set the DISTRO environment variable."
  exit 1
fi
if [ -z "${METHOD}" ]; then
  echo "Please set the METHOD environment variable."
  exit 1
fi
if [ -z "${SH}" ]; then
  echo "Please set the SH environment variable."
  exit 1
fi

# shellcheck disable=SC1090
. "./distros/${DISTRO}.sh"
if [ -z "${IMAGE}" ]; then
    echo "Test framework bug: the IMAGE variable is not set for the distro ${DISTRO}."
    exit 1
fi

CID=$(\
docker create -tiq \
   -v "$(realpath "$(pwd)/../../src"):/src" \
   -v "$(realpath "$(pwd)/../"):/tests" \
   -e "DISTRO=${DISTRO}" \
   -e "METHOD=${METHOD}" \
   -e "SH=${SH}" \
   -w /tests/linux \
   "${IMAGE}" \
   /tests/linux/test-helper.sh \
)

trap 'docker rm --force "${CID}" 2>&1 >/dev/null' EXIT
docker start -ai "${CID}"
