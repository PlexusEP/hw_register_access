#!/bin/bash

usage() {
    echo "  Generate a PCLP project configuration for the given target."
    echo "  Usage: ${0} <PCLP_BUILD_DIR> <CMAKE_TARGET> <SCOPE>"
    echo "  Example: ${0} /workspaces/cpp-project-template/build/linux_gcc_debug/pclp my_app project"
    exit 1
}

# Arguments:
#   1: absolute path to PCLP build directory
#   2: CMake target for which to produce compiler configuration
#   3: "project" to perform project lint, or path to file if analyzing single file

ABS_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

PCLP_BUILD_DIR=${1}
CMAKE_TARGET=${2}
SCOPE=${3}

if [[ ${1} = "--help" || -z "${PCLP_BUILD_DIR}" || -z "${CMAKE_TARGET}" || -z "${SCOPE}" ]]; then
   usage
fi

COMPILER_FAMILY_ARG=--compiler\=`cat ${PCLP_BUILD_DIR}/${CMAKE_TARGET}/pclp/compiler_family`
COMPILATION_DB_ARG=--compilation-db\=`cat ${PCLP_BUILD_DIR}/${CMAKE_TARGET}/pclp/compilation_db`

SINGLE_FILE_LINT_INCLUDE_ARG=
if [ "${SCOPE}" != "project" ]; then
    SINGLE_FILE_LINT_INCLUDE_ARG=--module-include-pattern=${SCOPE}
fi

#process module excludes
MODULE_EXCLUDES_ARG=""
while read line; do
    MODULE_EXCLUDES_ARG+="--module-exclude-pattern ${line} "
done < ${PCLP_BUILD_DIR}/${CMAKE_TARGET}/pclp/cfg_exclude_patterns

#process module includes
MODULE_INCLUDES_ARG=""
while read line; do
    MODULE_INCLUDES_ARG+="--module-include-pattern ${line} "
done < ${PCLP_BUILD_DIR}/${CMAKE_TARGET}/pclp/cfg_include_patterns

OPTIONAL_ARGS="${MODULE_EXCLUDES_ARG}"
OPTIONAL_ARGS+="${MODULE_INCLUDES_ARG}"
OPTIONAL_ARGS+="${SINGLE_FILE_LINT_INCLUDE_ARG}"

#generate project configuration
pushd ${PCLP_BUILD_DIR}/${CMAKE_TARGET}/pclp/ > /dev/null
if [ -z "${OPTIONAL_ARGS}" ]; then
    pclp_config.py \
        "${COMPILER_FAMILY_ARG}" \
        "${COMPILATION_DB_ARG}" \
        --config-output-lnt-file=project.lnt \
        --generate-project-config
else
    pclp_config.py \
        "${COMPILER_FAMILY_ARG}" \
        "${COMPILATION_DB_ARG}" \
        --config-output-lnt-file=project.lnt \
        --generate-project-config \
        ${OPTIONAL_ARGS}
fi
PCLP_PRJ_CFG_RESULT=${?}
popd > /dev/null
if [ ${PCLP_PRJ_CFG_RESULT} != 0 ]; then exit 1; fi
exit 0
