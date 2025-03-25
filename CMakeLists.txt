cmake_minimum_required(VERSION 3.28)

project(hw_register_access)

option(PLXS_HW_REG_DEV "Set to 'ON' when updating this library and need to use this repository stand-alone." OFF)

# ---- Include guards ----
if(PROJECT_SOURCE_DIR STREQUAL PROJECT_BINARY_DIR)
  message(FATAL_ERROR "In-source builds not allowed. Please make a new directory (called a build directory) and run CMake from there.")
endif()

list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/tools/cmake)

if (PLXS_HW_REG_DEV)
  include(policy)
  include(cpp)
  include(preprocessor-defines)
  include(gitversion)
  include(graphviz)
  include(pclp)
  include(test)
  add_subdirectory(apps)
endif()

add_subdirectory(libs)

if (PLXS_HW_REG_DEV)
  pclp_complete_configuration_after_targets_defined()
endif()
