#This module is intended to be included in the top-level CMakeLists.txt.
#It is a convenience mechanism for specifying preprocessor symbols from within CMakePresets.json.
#It picks out any CMake cache variables that start with "PP_" (where 'PP'
#is short for preprocessor) and takes one of three actions, depending on value:
#  1. if "PP_DEFINED", adds a compile definition (with default value)
#  2. if *not* "PP_UNDEFINED", adds a compile definition with the specified value
#  3. otherwise, ignores (does not define any preprocessor symbol)

get_cmake_property(PREPROCESSOR_CMAKE_VARS CACHE_VARIABLES)
list (FILTER PREPROCESSOR_CMAKE_VARS INCLUDE REGEX ^PP_*)
foreach (PP_VAR ${PREPROCESSOR_CMAKE_VARS})
    string(SUBSTRING ${PP_VAR} 3 -1 PPDEF)
    if(${${PP_VAR}} STREQUAL "PP_DEFINED") #if DEFINED
        add_compile_definitions(${PPDEF})
    elseif(NOT ${${PP_VAR}} STREQUAL "PP_UNDEFINED") #elseif NOT UNDEFINED
        add_compile_definitions(${PPDEF}=${${PP_VAR}})
    endif()
endforeach()
