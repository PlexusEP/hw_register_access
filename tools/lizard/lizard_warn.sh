#!/bin/bash
set -o noglob

ABS_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
source ${ABS_PATH}/lizard_exclude.sh

lizard -i0 ${EXCLUDE_ARGS}