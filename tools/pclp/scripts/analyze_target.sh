#!/bin/bash

usage() {
    echo "  Perform a PCLP analysis for the given target (and its dependencies)."
    echo "  Usage: ${0} <TGT_PCLP_OUT_DIR> <CMAKE_TARGET> <OUTPUT_LOG> <SUMMARY_LOG> <ADDITIONAL_OPTIONS>"
    echo "  Example: ${0} /workspaces/cpp-project-template/build/linux_gcc_debug/pclp my_app -unit_check"
    exit 1
}

# Arguments:
#   1: absolute path to the target's PCLP output directory
#   2: CMake target to analyze
#   3: name of file to use to log PCLP analysis output
#   4: name of file to use to summarize PCLP analysis
#   5: any other additional options to pass to the pclp64_linux command line

ABS_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

TGT_PCLP_OUT_DIR=${1}
CMAKE_TARGET=${2}
OUTPUT_LOG=${3}
SUMMARY_LOG=${4}
ADDITIONAL_OPTIONS=${5}

if [[ ${1} = "--help" || -z "${TGT_PCLP_OUT_DIR}" || -z "${CMAKE_TARGET}" || -z "${OUTPUT_LOG}" || -z "${SUMMARY_LOG}" ]]; then
   usage
fi

if [ ! -f ${TGT_PCLP_OUT_DIR}/registered_pclp_target ]; then
    #Skipping unregistered target
    exit 0
fi

pushd ${TGT_PCLP_OUT_DIR} > /dev/null
printf "\nAnalyzing target: ${CMAKE_TARGET}\n" | tee -a ${OUTPUT_LOG}
pclp64_linux ${ADDITIONAL_OPTIONS} -b std.lnt | tee -a ${OUTPUT_LOG}
PCLP_RESULT=${PIPESTATUS[0]}
echo ${PCLP_RESULT} > returncode.txt
popd > /dev/null

#create the target analysis summary
${ABS_PATH}/summarize_target_analysis.sh ${TGT_PCLP_OUT_DIR} ${OUTPUT_LOG} ${SUMMARY_LOG}

if [ ${PCLP_RESULT} != 0 ]; then exit 1; fi
exit 0
