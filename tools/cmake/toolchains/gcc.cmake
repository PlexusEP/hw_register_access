# CMake toolchain file for Linux Environment.
#
# Usage:
#
# To use this file, you need to set the 'CMAKE_TOOLCHAIN_FILE' to point to
# 'gcc.cmake' on the command line:
#
#   cmake -DCMAKE_TOOLCHAIN_FILE=/path/to/gcc.cmake

set(CMAKE_HOST_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR ${CMAKE_HOST_SYSTEM_PROCESSOR})
set(PLATFORM Linux)

set(CMAKE_C_COMPILER gcc CACHE STRING "Linux C Compiler" FORCE)
set(CMAKE_CXX_COMPILER g++ CACHE STRING "Linux C++ Compiler" FORCE)

# GCC supports sanitizers to provide dynamic analysis for memory, undefined behavior, 
# and thread safety.  These should run with the all GCC builds to attempt to catch these 
# unwanted behaviors and provided feedback on how/where they happened

set(SANITIZE_ADDRESS ON CACHE BOOL "Sanitize with ASan")
set(SANITIZE_UNDEFINED_BEHAVIOR ON CACHE BOOL "Sanitize with UBSan")
set(SANITIZE_THREAD OFF CACHE BOOL "Sanitize with TSan (Does not run with ASan or UBSan)")

# For now, don't use sanitizers with Debug configuration.  See https://github.com/google/sanitizers/issues/857.
# The issue appears to be related to attempting to simultaneously use ptrace from both gdb and LeakSanitizer.
if("${CMAKE_BUILD_TYPE}" STREQUAL "Release")

    if(${SANITIZE_ADDRESS})
        add_compile_options(-fsanitize=address)
        add_link_options(-fsanitize=address)
    endif()

    if(${SANITIZE_UNDEFINED_BEHAVIOR})
        add_compile_options(-fsanitize=undefined)
        add_link_options(-fsanitize=undefined)
    endif()

    if(${SANITIZE_THREAD})
        add_compile_options(-fsanitize=thread)
        add_link_options(-fsanitize=thread)
    endif()

endif()
