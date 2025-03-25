cmake_minimum_required(VERSION 3.28)

project(hw_register_access)

option(PLXS_HW_REG_BUILD_EXAMPLE_APPLICATIONS "Build the example application(s) for the PLXS Hardware Register Access library." OFF)

# ---- Include guards ----
if(PROJECT_SOURCE_DIR STREQUAL PROJECT_BINARY_DIR)
  message(FATAL_ERROR "In-source builds not allowed. Please make a new directory (called a build directory) and run CMake from there.")
endif()

list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/tools/cmake)

include(policy)
include(cpp)
include(preprocessor-defines)
include(gitversion)
include(graphviz)
include(pclp)
include(test)

add_subdirectory(apps)
add_subdirectory(libs)

pclp_complete_configuration_after_targets_defined()
