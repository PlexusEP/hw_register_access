#!/bin/bash

usage() {
    echo "  'Configure' to create inputs necessary for PCLP analysis."
    echo "  Usage: ${0} <SCOPE> <SRC_DIR> <PCLP_BUILD_DIR> <CMAKE_CFG_PRESET_NAME> <CMAKE_TARGET>"
    echo "  (single file) Example: ${0} /workspaces/cpp-project-template/apps/my_app/main.cpp /workspaces/cpp-project-template /workspaces/cpp-project-template/build/linux_gcc/pclp linux_gcc my_app"
    echo "  (project) Example: ${0} project /workspaces/cpp-project-template /workspaces/cpp-project-template/build/linux_gcc/pclp linux_gcc my_app"
    exit 1
}

# Arguments:
#   1: "project" to perform project lint, or path to file if analyzing single file
#   2: absolute path to the top-level source directory
#   3: absolute path to PCLP build directory
#   4: CMake configure preset name
#   5: CMake build target

ABS_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

SCOPE=${1}
SRC_DIR=${2}
PCLP_BUILD_DIR=${3}
CMAKE_CFG_PRESET_NAME=${4}
CMAKE_TARGET=${5}

if [[ ${1} = "--help" || -z "${SCOPE}" || -z "${SRC_DIR}" || -z "${PCLP_BUILD_DIR}" || -z "${CMAKE_CFG_PRESET_NAME}" || -z "${CMAKE_TARGET}" ]]; then
   usage
fi

# ---------- cmake configuration ----------

cmake_configure_single_target() {
    TGT=${1}
    rm -rf ${PCLP_BUILD_DIR}/${TGT}/pclp # clear any previous state
    while true; do
        ${ABS_PATH}/cmake_configure_target.sh ${SRC_DIR} ${PCLP_BUILD_DIR} ${TGT} ${CMAKE_CFG_PRESET_NAME}
        CMAKE_CFG_RESULT=${?}
        if [ ${CMAKE_CFG_RESULT} != 0 ]; then exit 1; fi

        STAGE=$(cat ${PCLP_BUILD_DIR}/${TGT}/pclp/stage)
        if [ ${STAGE} -gt 3 ]; then
            break
        fi
    done
}

# this CMake configuration is necessary since it generates the PCLP configuration inputs

cmake_configure_single_target ${CMAKE_TARGET}

#if target is 'all', also perform a CMake configure for each target comprising 'all' to produce PCLP inputs for that target
if [ ${CMAKE_TARGET} == "all" ]; then
    source ${ABS_PATH}/get_targets_in_all.sh ${PCLP_BUILD_DIR}
    for CUR_TARGET in "${TARGETS_IN_ALL[@]}"
        do : 
            cmake_configure_single_target ${CUR_TARGET}
        done
fi

# ---------- PCLP configuration ----------

if [ ${CMAKE_TARGET} == "all" ]; then
    source ${ABS_PATH}/get_targets_in_all.sh ${PCLP_BUILD_DIR}
    for CUR_TARGET in "${TARGETS_IN_ALL[@]}"
        do :
            ${ABS_PATH}/pclp_configure_target.sh ${PCLP_BUILD_DIR} ${CUR_TARGET} ${SCOPE}
            TGT_CFG_RESULT=${?}
            if [ ${TGT_CFG_RESULT} != 0 ]; then exit 2; fi
        done
else
    ${ABS_PATH}/pclp_configure_target.sh ${PCLP_BUILD_DIR} ${CMAKE_TARGET} ${SCOPE}
    TGT_CFG_RESULT=${?}
    if [ ${TGT_CFG_RESULT} != 0 ]; then exit 2; fi
fi

exit 0
