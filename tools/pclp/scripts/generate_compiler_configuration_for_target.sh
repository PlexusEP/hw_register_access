#!/bin/bash

usage() {
    echo "  Generate a PCLP compiler configuration for the given target."
    echo "  Usage: ${0} <PCLP_BUILD_DIR> <CMAKE_TARGET>"
    echo "  Example: ${0} /workspaces/cpp-project-template/build/linux_gcc_debug/pclp my_app"
    exit 1
}

# Arguments:
#   1: absolute path to PCLP build directory
#   2: CMake target for which to produce compiler configuration

ABS_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

PCLP_BUILD_DIR=${1}
CMAKE_TARGET=${2}

if [[ ${1} = "--help" || -z "${PCLP_BUILD_DIR}" || -z "${CMAKE_TARGET}" ]]; then
   usage
fi

COMPILER_FAMILY_ARG=--compiler\=`cat ${PCLP_BUILD_DIR}/${CMAKE_TARGET}/pclp/compiler_family`
COMPILER_BIN_ARG=--compiler-bin\=`cat ${PCLP_BUILD_DIR}/${CMAKE_TARGET}/pclp/compiler_bin`

#process generic compiler options
COMPILER_OPTIONS_ARG="--compiler-options="
while read line; do
    COMPILER_OPTIONS_ARG+="${line} "
done < ${PCLP_BUILD_DIR}/${CMAKE_TARGET}/pclp/cfg_generic_opts

#process C compiler options
COMPILER_C_OPTIONS_ARG="--compiler-c-options="
while read line; do
    COMPILER_C_OPTIONS_ARG+="${line} "
done < ${PCLP_BUILD_DIR}/${CMAKE_TARGET}/pclp/cfg_c_opts

#process CPP compiler options
COMPILER_CPP_OPTIONS_ARG="--compiler-cpp-options="
while read line; do
    COMPILER_CPP_OPTIONS_ARG+="${line} "
done < ${PCLP_BUILD_DIR}/${CMAKE_TARGET}/pclp/cfg_cpp_opts

pushd ${PCLP_BUILD_DIR}/${CMAKE_TARGET}/pclp/ > /dev/null
pclp_config.py \
    "${COMPILER_FAMILY_ARG}" \
    "${COMPILER_BIN_ARG}" \
    "${COMPILER_OPTIONS_ARG}" \
    "${COMPILER_C_OPTIONS_ARG}" \
    "${COMPILER_CPP_OPTIONS_ARG}" \
    --config-output-lnt-file=compiler.lnt \
    --config-output-header-file=compiler.h \
    --generate-compiler-config
PCLP_CMP_CFG_RESULT=${?}
popd > /dev/null
if [ ${PCLP_CMP_CFG_RESULT} != 0 ]; then exit 1; fi
exit 0
