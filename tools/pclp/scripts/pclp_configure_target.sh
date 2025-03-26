#!/bin/bash

usage() {
    echo "  Generate PCLP configuration (compiler configuration and project configuration) for the given target."
    echo "  Usage: ${0} <PCLP_BUILD_DIR> <TARGET> <SCOPE>"
    echo "  Example: ${0} /workspaces/cpp-project-template/build/linux_gcc_debug/pclp my_app linux_gcc project"
    exit 1
}

# Arguments:
#   1: absolute path to PCLP build directory
#   2: CMake target for which to perform PCLP configuration
#   3: "project" to perform project lint, or path to file if analyzing single file

ABS_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

PCLP_BUILD_DIR=${1}
TARGET=${2}
SCOPE=${3}

if [[ ${1} = "--help" || -z "${PCLP_BUILD_DIR}" || -z "${TARGET}" || -z "${SCOPE}" ]]; then
   usage
fi

if [ ! -f ${PCLP_BUILD_DIR}/${TARGET}/pclp/registered_pclp_target ]; then
    exit 0
fi

${ABS_PATH}/generate_compiler_configuration_for_target.sh ${PCLP_BUILD_DIR} ${TARGET}
COMPILER_CFG_RESULT=${?}
if [ ${COMPILER_CFG_RESULT} != 0 ]; then exit 1; fi

${ABS_PATH}/generate_project_configuration_for_target.sh ${PCLP_BUILD_DIR} ${TARGET} ${SCOPE}
PROJECT_CFG_RESULT=${?}
if [ ${PROJECT_CFG_RESULT} != 0 ]; then exit 2; fi

exit 0
