#!/bin/bash
################################################################################
# File:    buildDocumentation.sh
# Purpose: Script that builds multiple versions of our documentation.
#           Based on the buildDocs.sh found here: 
#           https://tech.michaelaltfield.net/2020/07/23/sphinx-rtd-github-pages-2/
#
# Authors: Michael Altfield <michael@michaelaltfield.net>
# Changes: Harry K.
# Created: 2020-07-17
# Updated: 2023-01-10
# Version: 0.6.3
################################################################################

usage() {
    echo "Build multiple versions of our documentation"
    echo "  Usage: ${0} <build output folder>"
    echo "  Example: ${0} build"
    exit 1
}

#########
# SETUP
#########

### Create build directory to compile all versions ###
TEMP_BUILD_DIR=${1}

if [[ ${TEMP_BUILD_DIR} = "--help" || -z "${TEMP_BUILD_DIR}" ]]; then
   usage
fi

# Clear out old _build directories - FOR DEBUG ONLY
#rm -d -r TEMP_BUILD_DIR=${1}

mkdir -p ${TEMP_BUILD_DIR}
######################

# Create the documentation directories for overall sections
mkdir ${TEMP_BUILD_DIR}/docs/    # Used to contain 'Latest' dir, for the latest tag
mkdir ${TEMP_BUILD_DIR}/docs/Previous_Versions/

LATEST="${TEMP_BUILD_DIR}/docs"  # Removed individual 'Latest' folder so formatting is more clear. 
PREV="${TEMP_BUILD_DIR}/docs/Previous_Versions"

# Save current branch to return to later
current_branch="`git branch '--show-current'`"

# Currently configured to find all tags matching the pattern 'versioning*',
# Input the list of tags/versions provided by the user
versions="`git tag -l docs-*`"
echo -e "\t Avaiable versions: ${versions}" 
if [[ $2 != '' ]]; then
   # Store input argument for main page.
   latest_version=($2);
else
   # Use current working branch as the main page
   latest_version=${current_branch};
fi

# TODO: allow user to specify an ignore list (with a file, argument, etc)
# and skip copying the docs if the current version matches a skipped version.
# compile all the versions listed into one one build directory
for current_version in ${versions[@]}; do

   echo -e "\tINFO: Current version: ${current_version}"
   git checkout ${current_version}
   # Error checking for successful checkout execution
   if [ ${?} != 0 ]; then
      continue;
   fi

   echo -e "\tINFO: Checking ${current_version} for docs"

   # Validation of documentation folder.
   pwd
   if [ ! -e './docs/' ]; then
      echo -e "\tINFO: (skipped) Couldn't find documentation folder GIT_ROOT/docs" # GIT_ROOT is placeholder name
      continue
   fi

   ##########
   # Document Fetching #
   ##########

   # Verify if tag is our "Latest"
   if [ ${current_version} == ${latest_version} ]; then
      echo -e "\tINFO: Building ${current_version} as latest version";

      # Store as the main page for the site (previously a subsection called 'Latest')
      CURRENT_DOCS="${LATEST}";
    else

      # Automatically 'register' the previous version and add to directory
      mkdir ${PREV}/${current_version};
      CURRENT_DOCS="${PREV}/${current_version}";
   fi
   
   pwd
   # Copy over the documentation to the proper directory.
   cp -r ./docs/* ${CURRENT_DOCS}/
   echo -e "\tINFO: Copied docs for ${current_version} to ${CURRENT_DOCS}"

# Make sure we return to the correct build directory when we leave.
done

# Return to current working branch
git checkout ${current_branch}

# Copy our current branch's config options
cp ./mkdocs.yml ${TEMP_BUILD_DIR}
cp -R ./docs/* ${TEMP_BUILD_DIR}/docs

# Build based on all the collected tags/versions
cd ${TEMP_BUILD_DIR}
pwd

# We'll keep site directory in overarching documentation directory
mkdocs build -d ../site -v