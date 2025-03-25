#!/bin/bash

usage() {
    echo "  Performs static analysis using PC-lint Plus."
    echo "  Usage: ${0} <SCOPE> <PCLP_BUILD_DIR> <SRC_DIR> <CMAKE_CFG_PRESET_NAME> <CMAKE_BLD_TGT>"
    echo "  (single file) Example: ${0} /workspaces/cpp-project-template/apps/my_app/main.cpp /workspaces/cpp-project-template/build/linux_gcc/pclp /workspaces/cpp-project-template linux_gcc my_app"
    echo "  (project) Example: ${0} project /workspaces/cpp-project-template/build/linux_gcc/pclp /workspaces/cpp-project-template linux_gcc my_app"
    exit 1
}

# Arguments:
#   1: "project" to perform project lint, or path to file if analyzing single file
#   2: absolute path to PCLP build directory
#   3: absolute path to the top-level source directory
#   4: CMake configure preset name
#   5: CMake build target

ABS_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

SCOPE=${1}
PCLP_BUILD_DIR=${2}
SRC_DIR=${3}
CMAKE_CFG_PRESET_NAME=${4}
CMAKE_BLD_TGT=${5}
TGT_OUTPUT_LOG=output.txt
TGT_SUMMARY_LOG=summary.txt
OVERALL_SUMMARY_LOG_PATH=${PCLP_BUILD_DIR}/summary.txt

if [[ ${1} = "--help" || -z "${SCOPE}" || -z "${PCLP_BUILD_DIR}" || -z "${SRC_DIR}" || -z "${CMAKE_CFG_PRESET_NAME}" || -z "${CMAKE_BLD_TGT}" ]]; then
    usage
fi

add_tgt_summary_to_overall_summary() {
    TGT=${1}
    TGT_SUMMARY_LOG_FILE=${2}
    if [ -f ${TGT_SUMMARY_LOG_FILE} ]; then
        echo "Analysis Target: ${TGT}" >> ${OVERALL_SUMMARY_LOG_PATH}
        cat ${TGT_SUMMARY_LOG_FILE} >> ${OVERALL_SUMMARY_LOG_PATH}
        echo "" >> ${OVERALL_SUMMARY_LOG_PATH}
    fi
}

display_summary() {
    if [ -f ${OVERALL_SUMMARY_LOG_PATH} ]; then
        echo ""
        echo ""
        echo "---------- Analysis Summary ----------"
        echo ""
        cat ${OVERALL_SUMMARY_LOG_PATH}
    else
        echo "No analysis targets defined in current CMake configuration."
        echo ""
    fi
}

ADDITIONAL_OPTIONS=
if [ "${SCOPE}" != "project" ]; then
    ADDITIONAL_OPTIONS=-unit_check
fi

if [ ! -f ${TOOL_INSTALL_DIR}/${PCLP_INSTALL_DIR}/linux/*.lic ]; then
    echo -e "No PC-Lint Plus license file found.  You must be connected to the PLXS network during at least one development container startup in order to automatically retrieve license. Once connected to the PLXS network you can run the VS Code command named 'Dev Containers: Rebuild Container' in order to force container restart."
    exit 2
fi

#special-case: vs code user has not [yet] selected build target, so vs code defaults to this value - treat it as 'all'
if [ "${CMAKE_BLD_TGT}" == "[Targets In Preset]" ]; then
    CMAKE_BLD_TGT="all"
fi

#configure to produce all the necessary inputs prior to analysis
${ABS_PATH}/configure.sh ${SCOPE} ${SRC_DIR} ${PCLP_BUILD_DIR} ${CMAKE_CFG_PRESET_NAME} ${CMAKE_BLD_TGT}
CFG_RSLT=${?}
if [ ${CFG_RSLT} != 0 ]; then exit 5; fi

#clear out any previous summary
rm -rf ${OVERALL_SUMMARY_LOG_PATH}

RESULT=0
if [ ${CMAKE_BLD_TGT} == "all" ]; then
    #if 'all' target, configure for each target comprising 'all' (get this list from file)
    #and perform a separate analysis for each one, but combine the return codes into a single one
    source ${ABS_PATH}/get_targets_in_all.sh ${PCLP_BUILD_DIR}
    for CUR_TARGET in "${TARGETS_IN_ALL[@]}"
        do : 
            TGT_PCLP_OUT_DIR=${PCLP_BUILD_DIR}/${CUR_TARGET}/pclp
            ${ABS_PATH}/analyze_target.sh ${TGT_PCLP_OUT_DIR} ${CUR_TARGET} ${TGT_OUTPUT_LOG} ${TGT_SUMMARY_LOG} ${ADDITIONAL_OPTIONS}
            CUR_RESULT=${?}
            if [ ${CUR_RESULT} != 0 ]; then RESULT=${CUR_RESULT}; fi
            add_tgt_summary_to_overall_summary ${CUR_TARGET} ${TGT_PCLP_OUT_DIR}/${TGT_SUMMARY_LOG}
        done
else
    TGT_PCLP_OUT_DIR=${PCLP_BUILD_DIR}/${CMAKE_BLD_TGT}/pclp
    ${ABS_PATH}/analyze_target.sh ${TGT_PCLP_OUT_DIR} ${CMAKE_BLD_TGT} ${TGT_OUTPUT_LOG} ${TGT_SUMMARY_LOG} ${ADDITIONAL_OPTIONS}
    RESULT=${?}
    add_tgt_summary_to_overall_summary ${CMAKE_BLD_TGT} ${TGT_PCLP_OUT_DIR}/${TGT_SUMMARY_LOG}
fi

display_summary

exit ${RESULT}
