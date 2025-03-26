#!/bin/bash

usage() {
    echo "Render multiple versions of our documentation"
    echo "  Usage: ${0} <folder where mkdocs yml and md files are located>"
    echo "  Example: ${0} build"
    exit 1
}

BUILD_DIR=${1}

if [[ ${BUILD_DIR} = "--help" || -z "${BUILD_DIR}" ]]; then
   usage
fi

source ./docs/buildDocumentation.sh ${BUILD_DIR}

cd ${BUILD_DIR}
mkdocs serve --dev-addr 0.0.0.0:8000
 