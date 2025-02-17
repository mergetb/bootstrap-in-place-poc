#!/bin/bash

set -euxo pipefail

if [ -z ${RELEASE_IMAGE+x} ]; then
	echo "Please set RELEASE_IMAGE"
	exit 1
fi

if [ -z ${INSTALLER_BIN+x} ]; then
	echo "Please set INSTALLER_BIN"
	exit 1
fi

if [ -z ${INSTALLER_WORKDIR+x} ]; then
	echo "Please set INSTALLER_WORKDIR"
	exit 1
fi

echo Generating manifests...

OPENSHIFT_INSTALL_RELEASE_IMAGE_OVERRIDE="${RELEASE_IMAGE}" \
${INSTALLER_BIN} create manifests --dir=${INSTALLER_WORKDIR}
