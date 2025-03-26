#!/bin/bash

usage() {
    echo "  Retrieves a list of all the individual targets comprising 'all' and returns them in the TARGETS_IN_ALL variable."
    echo "  Usage: ${0} <PCLP_BUILD_DIR>"
    echo "  Example: ${0} /workspaces/cpp-project-template/build/linux_gcc_debug/pclp"
    exit 1
}

# Arguments:
#   1: absolute path to PCLP build directory

ABS_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

#get list of targets comprising 'all' that was recorded to file during CMake configuration
mapfile -t TARGETS_IN_ALL < ${PCLP_BUILD_DIR}/all/pclp/targets_in_all.txt
export TARGETS_IN_ALL=${TARGETS_IN_ALL}
