#This logic sets COMPILER_ID as reported by CMake, and checks to ensure it is one that is supported here. As a side effect, this function also checks
#to ensure the C and CXX compilers share the same ID, since a limitation of PCLP is that it only supports a single compiler "family" during compiler configuration.
#   VARIANT - output, compiler ID as reported by CMake (e.g., "GNU" or "IAR")
if(NOT "${CMAKE_C_COMPILER_ID}" STREQUAL "${CMAKE_CXX_COMPILER_ID}")
    message(FATAL_ERROR "C and CXX CMake compiler variants differ (${C_VARIANT} and ${CXX_VARIANT}, respectively). However, PCLP supports only a single compiler family (based on CMake compiler variant) per compiler configuration/analysis.")
endif()

set(COMPILER_ID "${CMAKE_CXX_COMPILER_ID}")