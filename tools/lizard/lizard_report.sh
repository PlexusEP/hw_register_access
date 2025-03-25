#!/bin/bash
set -o noglob

usage() {
    echo "Generates a cyclomatic complexity report using Lizard in the given output report path for the current project"
    echo "Optioanlly, it is possible to provide patterns of files to exclude from the report."
    echo "  Usage: ${0} <output report path> [exclude-args...]"
    echo "  Example, run lizard and exclude anything from tests folder: ${0} ./output-report ./tests/*"
    exit 1
}

REPORT_DIR=${1}
shift
ABS_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
source ${ABS_PATH}/lizard_exclude.sh

if [[ ${REPORT_DIR} = "--help" || -z "${REPORT_DIR}" ]]; then
   usage
fi

# Construct exclude paths from remaining arguments
for arg in "$@"
do
    EXCLUDE_ARGS="${EXCLUDE_ARGS} -x ${arg}"
done

mkdir -p ${REPORT_DIR}
set -x
lizard \
    ${EXCLUDE_ARGS} \
    --html -o ${REPORT_DIR}/index.html
set +x
