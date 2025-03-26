#!/bin/bash

usage() {
    echo "  Perform a CMake configuration for the given target, producing a target-specific compilation DB and other analysis inputs."
    echo "  Usage: ${0} <SRC_DIR> <PCLP_BUILD_DIR> <CMAKE_TARGET> <CMAKE_CFG_PRESET_NAME>"
    echo "  Example: ${0} /workspaces/cpp-project-template /workspaces/cpp-project-template/build/linux_gcc_debug/pclp my_app linux_gcc"
    exit 1
}

# Arguments:
#   1: absolute path to the top-level source directory
#   2: absolute path to PCLP build directory
#   3: CMake target for which to produce CMake configuration
#   4: CMake configure preset name

ABS_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

SRC_DIR=${1}
PCLP_BUILD_DIR=${2}
CMAKE_TARGET=${3}
CMAKE_CFG_PRESET_NAME=${4}

if [[ ${1} = "--help" || -z "${SRC_DIR}" || -z "${PCLP_BUILD_DIR}" || -z "${CMAKE_TARGET}" || -z "${CMAKE_CFG_PRESET_NAME}" ]]; then
   usage
fi

if [ ${CMAKE_TARGET} == "all" ]; then
    CMAKE_COMP_DB_OPT=ON
else
    CMAKE_COMP_DB_OPT=OFF
fi

pushd ${SRC_DIR} > /dev/null
cmake -B ${PCLP_BUILD_DIR}/${CMAKE_TARGET} --preset ${CMAKE_CFG_PRESET_NAME} -DCMAKE_EXPORT_COMPILE_COMMANDS=${CMAKE_COMP_DB_OPT} -DPCLP_TARGET=${CMAKE_TARGET} > /dev/null
CMAKE_CFG_RESULT=${?}
popd > /dev/null
if [ ${CMAKE_CFG_RESULT} != 0 ]; then exit 1; fi
exit 0
