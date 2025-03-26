#!/bin/bash

usage() {
    echo "Add a new line character At EOF"
    echo "  Usage: ${0} <input file>"
    echo "  Example: ${0} my-file.cpp"
    exit 1
}

FILE_TO_FORMAT=$1

if [[ ${FILE_TO_FORMAT} = "--help" || -z "${FILE_TO_FORMAT}" ]]; then
   usage
fi

if [[ $(tail -c1 ${FILE_TO_FORMAT}) && -f ${FILE_TO_FORMAT} ]]
then
    echo '' >> ${FILE_TO_FORMAT}
else
    exit 0
fi
