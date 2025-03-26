#!/bin/bash

usage() {
    echo "Creates files and folder structure for a new application within the provided path"
    echo "  Usage: ${0} <application name> <application path>"
    echo "  Example: ${0} my-new-app-name ./my-new-app/"
    exit 1
}

ABS_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

APP_NAME=${1}
APP_DIR=${2}

if [[ ${APP_NAME} = "--help" || -z "${APP_NAME}" || -z "${APP_DIR}" ]]; then
   usage
fi

# Make sure application directory does not already exist
if [ -e ${APP_DIR}/${APP_NAME} ]
then
    echo "The path ${APP_DIR}/${APP_NAME} already exists!"
    echo "Cannot create application directory structure. Aborting"
    exit 1
fi

echo Creating application named ${APP_NAME} within ${APP_DIR}...

#create directory structure
mkdir -p ${APP_DIR}/${APP_NAME}/private

#create stub files
touch ${APP_DIR}/${APP_NAME}/private/${APP_NAME}.cpp

#add main function to application
echo -e "int main(int /*argc*/, char* /*argv*/[]) {}" > ${APP_DIR}/${APP_NAME}/private/${APP_NAME}.cpp

#add the application to the higher-level CMakeLists.txt
echo -e "add_subdirectory(${APP_NAME})" >> ${APP_DIR}/CMakeLists.txt

#create application CMakeLists.txt
cp ${ABS_PATH}/CMakeLists.txt.template ${APP_DIR}/${APP_NAME}/CMakeLists.txt
sed -i 's/APP_NAME/'"${APP_NAME}"'/g' ${APP_DIR}/${APP_NAME}/CMakeLists.txt
