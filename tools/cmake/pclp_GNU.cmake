#----- helper functions -----

#This function returns the prefix that should be used when specifying language standard
#   LANG - input, language compiler to check (either C or CXX)
#   STD_OPT_PREFIX - output, prefix to use when specifying standard for the given language (e.g., "c" for "-std=c11" or "gnu" for "-std=gnu11")
function(pclp_get_std_opt_prefix LANG STD_OPT_PREFIX)
    if((NOT "${LANG}" STREQUAL "C") AND (NOT "${LANG}" STREQUAL "CXX"))
        message(FATAL_ERROR "PCLP static analysis does not support the ${LANG} language.")
    endif()

    if(CMAKE_${LANG}_EXTENSIONS)
        set(${STD_OPT_PREFIX} "gnu" PARENT_SCOPE)
    else()
        set(${STD_OPT_PREFIX} "c" PARENT_SCOPE)
    endif()
endfunction()


#----- required implementations -----

#This function takes the given options and scans each entry for any mention of specification of C and/or CXX version.  If any option specifies version of
#C or C++, it flags a CMake fatal error.  See PLXSEP-1004 for more information about PCLP tool issue related to multiple, conflicting C/C++ version options.
#   OPTS - input, the options to scan
function(pclp_check_compiler_opt_for_std_spec OPTS FOUND)
    list(FILTER OPTS INCLUDE REGEX "\\-std=.*")
    list(LENGTH OPTS FLT_NUM)
    if(FLT_NUM GREATER 0)
        set(${FOUND} TRUE PARENT_SCOPE)
    else()
        set(${FOUND} FALSE PARENT_SCOPE)
    endif()
endfunction()

#This function returns compiler family as reported by CMake (per toolchain).
#   PCLP_COMPILER_FAMILY - output, compiler family
function(pclp_get_compiler_family PCLP_COMPILER_FAMILY)
    set(${PCLP_COMPILER_FAMILY} "gcc" PARENT_SCOPE)
endfunction()

function(pclp_get_compiler_cfg_options_general CMP_CFG_OPT_GEN)
    set(${CMP_CFG_OPT_GEN} "" PARENT_SCOPE)
endfunction()

function(pclp_get_compiler_cfg_options_c CMP_CFG_OPT_C)
    pclp_get_std_opt_prefix("C" STD_C_OPT_PREFIX)
    set(CMP_CFG_OPT_C "-std=${STD_C_OPT_PREFIX}${CMAKE_C_STANDARD}" PARENT_SCOPE)
endfunction()

function(pclp_get_compiler_cfg_options_cxx CMP_CFG_OPT_CXX)
    pclp_get_std_opt_prefix("CXX" STD_CXX_OPT_PREFIX)
    set(${CMP_CFG_OPT_CXX} "-std=${STD_CXX_OPT_PREFIX}++${CMAKE_CXX_STANDARD}" PARENT_SCOPE)
endfunction()

function(pclp_get_toolchain_specific_analysis_options_files PCLP_TOOLCHAIN_ANALYSIS_OPT_FILES)
    #no GNU-specific analysis options files
    set(${PCLP_TOOLCHAIN_ANALYSIS_OPT_FILES} "" PARENT_SCOPE)
endfunction()