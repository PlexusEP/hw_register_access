#!/bin/bash

usage() {
    echo "  Summarize a single target's PCLP analysis results."
    echo "  Usage: ${0} <TGT_PCLP_OUT_DIR> <OUTPUT_LOG_NAME> <SUMMARY_LOG_NAME>"
    echo "      TGT_PCLP_OUT_DIR: absolute path to the target's PCLP output directory"
    echo "      OUTPUT_LOG_NAME: name of log file containing all analysis results"
    echo "      SUMMARY_LOG_NAME: name of summary log file"
    echo "  Example: ${0} /workspaces/cpp-project-template/build/linux_gcc_debug/pclp output.txt summary.txt"
    exit 1
}

ABS_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

TGT_PCLP_OUT_DIR=${1}
OUTPUT_LOG_NAME=${2}
SUMMARY_LOG_NAME=${3}

ERROR_MATCHER="Type: error"
WARNING_MATCHER="Type: warning"
INFO_MATCHER="Type: info"
NOTE_MATCHER="Type: note"

if [[ ${1} = "--help" || -z "${TGT_PCLP_OUT_DIR}" || -z "${OUTPUT_LOG_NAME}" || -z "${SUMMARY_LOG_NAME}" ]]; then
   usage
fi

pushd ${TGT_PCLP_OUT_DIR} > /dev/null
printf "Errors: " > ${SUMMARY_LOG_NAME}
grep -o "${ERROR_MATCHER}" ${OUTPUT_LOG_NAME} | wc -l >> ${SUMMARY_LOG_NAME}
printf "Warnings: " >> ${SUMMARY_LOG_NAME}
grep -o "${WARNING_MATCHER}" ${OUTPUT_LOG_NAME} | wc -l >> ${SUMMARY_LOG_NAME}
printf "Infos: " >> ${SUMMARY_LOG_NAME}
grep -o "${INFO_MATCHER}" ${OUTPUT_LOG_NAME} | wc -l >> ${SUMMARY_LOG_NAME}
printf "Notes: " >> ${SUMMARY_LOG_NAME}
grep -o "${NOTE_MATCHER}" ${OUTPUT_LOG_NAME} | wc -l >> ${SUMMARY_LOG_NAME}
popd > /dev/null
