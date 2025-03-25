#!/bin/bash

usage() {
    echo "Creates files and folder structure for a new library within the provided path"
    echo "  Usage: ${0} <library name> <library path>"
    echo "  Example: ${0} my-new-library-name ./my-new-library/"
    exit 1
}

ABS_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

LIB_NAME=${1}
LIB_DIR=${2}

if [[ ${LIB_NAME} = "--help" || -z "${LIB_NAME}" || -z "${LIB_DIR}" ]]; then
   usage
fi

# Make sure library directory does not already exist
if [ -e ${LIB_DIR}/${LIB_NAME} ]
then
    echo "The path ${LIB_DIR}/${LIB_NAME} already exists!"
    echo "Cannot create library directory structure. Aborting"
    exit 1
fi

echo Creating library named ${LIB_NAME} within ${LIB_DIR}...

#create directory structure
mkdir -p ${LIB_DIR}/${LIB_NAME}/public/${LIB_NAME}
mkdir -p ${LIB_DIR}/${LIB_NAME}/private
mkdir -p ${LIB_DIR}/${LIB_NAME}/test

#add the library project to the higher-level CMakeLists.txt
echo -e "add_subdirectory(${LIB_NAME})" >> ${LIB_DIR}/CMakeLists.txt

#create library CMakeLists.tx1t
cp ${ABS_PATH}/CMakeLists.txt.template ${LIB_DIR}/${LIB_NAME}/CMakeLists.txt
sed -i 's/LIB_NAME/'"${LIB_NAME}"'/g' ${LIB_DIR}/${LIB_NAME}/CMakeLists.txt

#create library sources
cp ${ABS_PATH}/lib_private.hpp.template ${LIB_DIR}/${LIB_NAME}/private/${LIB_NAME}_private.hpp
sed -i 's/LIB_NAME/'"${LIB_NAME}"'/g' ${LIB_DIR}/${LIB_NAME}/private/${LIB_NAME}_private.hpp
cp ${ABS_PATH}/lib_private.cpp.template ${LIB_DIR}/${LIB_NAME}/private/${LIB_NAME}.cpp
sed -i 's/LIB_NAME/'"${LIB_NAME}"'/g' ${LIB_DIR}/${LIB_NAME}/private/${LIB_NAME}.cpp
cp ${ABS_PATH}/lib_public.hpp.template ${LIB_DIR}/${LIB_NAME}/public/${LIB_NAME}/${LIB_NAME}_public.hpp
sed -i 's/LIB_NAME/'"${LIB_NAME}"'/g' ${LIB_DIR}/${LIB_NAME}/public/${LIB_NAME}/${LIB_NAME}_public.hpp

#set up the test folder contents
cp ${ABS_PATH}/test.CMakeLists.txt.template ${LIB_DIR}/${LIB_NAME}/test/CMakeLists.txt
sed -i 's/LIB_NAME/'"${LIB_NAME}"'/g' ${LIB_DIR}/${LIB_NAME}/test/CMakeLists.txt
cp ${ABS_PATH}/test.cpp.template ${LIB_DIR}/${LIB_NAME}/test/test_${LIB_NAME}.cpp
sed -i 's/LIB_NAME/'"${LIB_NAME}"'/g' ${LIB_DIR}/${LIB_NAME}/test/test_${LIB_NAME}.cpp
