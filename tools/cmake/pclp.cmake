include(target_properties)
include(strings)
include(lists)
include(pclp_compiler_id)
include(pclp_${COMPILER_ID}) #provides compiler-specific implementations of a pre-defined set of functions

# --------------------------------- PUBLIC FUNCTIONS ---------------------------------

#This function must be run after all targets have been defined, typically toward the end of the top-level CMakeLists.txt.
#It performs all the PCLP CMake wrap functionality that depends on targets being defined, and is broken into several
#stages that span multiple cmake CLI invocations due to the potential need to resolve generator expressions.
#Together with pclp_single_target_configuration this function iteratively completes the process of PCLP configuration
#for the active build target, provided that target is a registered analysis target.
function(pclp_complete_configuration_after_targets_defined)
    #only take action when the PCLP_TARGET is defined
    if(NOT DEFINED PCLP_TARGET)
        return()
    endif()

    #For special case - 'all' target - include all targets not within EXCLUDE_FROM_ALL,
    #and output list of targets so PCLP script knows which to run (as a set of targets).
    pclp_output_targets_in_all()

    #skip remaining stages if this is not a registered analysis target (thus letting the associated scripting know to continue on)
    is_pclp_target_registered(IS_REGISTERED)
    if(NOT ${IS_REGISTERED})
        skip_stages()
        return()
    endif()

    get_stage(STAGE)

    #stage 0 - see pclp_single_target_configuration, defined below

    if(STAGE EQUAL 1)
        #resolve target references that may include generator expressions
        produce_resolved_target_dependencies_list(${PCLP_TARGET} ACTIVE_TGT_DONE) #may need to be invoked multiple times to complete
        if(${ACTIVE_TGT_DONE})
            next_stage()
        endif()
    elseif(STAGE EQUAL 2)
        #resolve library target references that may include generator expressions
        #resolve relevant library target properties that may include generator expressions
        pclp_process_library_targets(LIB_TARGETS_DONE) #may need to be invoked multiple times to complete
        if(${LIB_TARGETS_DONE})
            next_stage()
        endif()
    elseif(STAGE EQUAL 3)
        #produce a single compilation database that includes sources for all targets comprising the active analysis target
        #post-process resolved, relevant library target properties
        pclp_single_target_compilation_db()
        pclp_process_lib_tgt_props()
        next_stage()
    endif()
endfunction()

#This function is intended to be called in any CMakeLists.txt file that defines a target to register and configure for PCLP analysis.
#However, it only ever acts on a single target at a time. It defines stage 0 of the multi-stage configuration process and records
#configuration information that is already available at this stage for later processing.  See MkDocs documentation for descriptions
#of each of the optional parameters to this function.
#   TGT - input, the target that is being registered for PCLP analysis, and whose PCLP configuration is being specified
function(pclp_single_target_configuration TGT)
    #only take action when the PCLP_TARGET is defined
    if(NOT DEFINED PCLP_TARGET)
        return()
    endif()

    #we're only ever configuring a single (i.e., "active") analysis target (TGT)
    if(NOT "${PCLP_TARGET}" STREQUAL "${TGT}")
        return()
    endif()

    #only run during stage 0
    get_stage(STAGE)
    if(NOT STAGE EQUAL 0)
        return()
    endif()

    set(multiValueArgs 
        COMPILER_CFG_GENERIC_OPTIONS
        COMPILER_CFG_C_OPTIONS
        COMPILER_CFG_CPP_OPTIONS
        PROJECT_CFG_INCLUDE_PATTERNS
        PROJECT_CFG_EXCLUDE_PATTERNS
        LIBRARY_DIRS
        LIBRARY_TARGETS
        LIBRARY_OPTIONS_FILES
        ANALYSIS_OPTIONS
        ANALYSIS_OPTIONS_FILES)
    cmake_parse_arguments(PCLP "" "" "${multiValueArgs}" ${ARGN})

    #C and C++ language versions *must* be inherited from CMake, to ensure consistency with build
    pclp_check_compiler_opt_for_std_spec("${PCLP_COMPILER_CFG_GENERIC_OPTIONS}" GEN_OPTS_CONTAIN_STD)
    pclp_check_compiler_opt_for_std_spec("${PCLP_COMPILER_CFG_C_OPTIONS}" C_OPTS_CONTAIN_STD)
    pclp_check_compiler_opt_for_std_spec("${PCLP_COMPILER_CFG_CPP_OPTIONS}" CXX_OPTS_CONTAIN_STD)
    if (GEN_OPTS_CONTAIN_STD OR C_OPTS_CONTAIN_STD OR CXX_OPTS_CONTAIN_STD)
        message(FATAL_ERROR "Specifying C/C++ language version via this PCLP API is forbidden. Specify using CMAKE_<LANG>_STANDARD within CMake instead.")
    endif()

    #automatically detect and set other inputs to PCLP configuration and analysis
    pclp_get_compiler_family(PCLP_COMPILER_FAMILY)
    set(PCLP_COMPILER_BIN "${CMAKE_CXX_COMPILER}")
    set(PCLP_COMPILATION_DB "${CMAKE_BINARY_DIR}/compile_commands.json")
    
    #note that these file names must be consistent with those referenced within the PCLP analyze script
    file(WRITE "${CMAKE_BINARY_DIR}/pclp/compiler_family" "${PCLP_COMPILER_FAMILY}")
    file(WRITE "${CMAKE_BINARY_DIR}/pclp/compiler_bin" "${PCLP_COMPILER_BIN}")
    file(WRITE "${CMAKE_BINARY_DIR}/pclp/compilation_db" "${PCLP_COMPILATION_DB}")
    pclp_get_compiler_cfg_options_general(CMP_CFG_OPT_GEN)
    list(APPEND PCLP_COMPILER_CFG_GENERIC_OPTIONS ${CMP_CFG_OPT_GEN})
    write_list_to_file(PCLP_COMPILER_CFG_GENERIC_OPTIONS "${CMAKE_BINARY_DIR}/pclp/cfg_generic_opts" WRITE)
    pclp_get_compiler_cfg_options_c(CMP_CFG_OPT_C)
    list(APPEND PCLP_COMPILER_CFG_C_OPTIONS ${CMP_CFG_OPT_C})
    write_list_to_file(PCLP_COMPILER_CFG_C_OPTIONS "${CMAKE_BINARY_DIR}/pclp/cfg_c_opts" WRITE)
    pclp_get_compiler_cfg_options_cxx(CMP_CFG_OPT_CXX)
    list(APPEND PCLP_COMPILER_CFG_CPP_OPTIONS ${CMP_CFG_OPT_CXX})
    write_list_to_file(PCLP_COMPILER_CFG_CPP_OPTIONS "${CMAKE_BINARY_DIR}/pclp/cfg_cpp_opts" WRITE)
    write_list_to_file(PCLP_PROJECT_CFG_INCLUDE_PATTERNS "${CMAKE_BINARY_DIR}/pclp/cfg_include_patterns" WRITE)

    #global and target-specific options
    file(GLOB_RECURSE LNT_FILES "${CMAKE_SOURCE_DIR}/tools/pclp/global_configuration/*.lnt")
    file(COPY ${LNT_FILES} DESTINATION "${CMAKE_BINARY_DIR}/pclp/")
    pclp_get_toolchain_specific_analysis_options_files(PCLP_TOOLCHAIN_ANALYSIS_OPT_FILES)
    list(APPEND PCLP_ANALYSIS_OPTIONS_FILES ${PCLP_TOOLCHAIN_ANALYSIS_OPT_FILES})
    pclp_generate_target_options_file("${PCLP_ANALYSIS_OPTIONS}" "${PCLP_ANALYSIS_OPTIONS_FILES}")

    #global and target-specific libraries
    file(COPY "${CMAKE_SOURCE_DIR}/tools/pclp/global_configuration/global_libraries.lnt" DESTINATION "${CMAKE_BINARY_DIR}/pclp/")
    pclp_generate_target_libraries_file("${PCLP_LIBRARY_DIRS}" "${PCLP_LIBRARY_TARGETS}" "${PCLP_LIBRARY_OPTIONS_FILES}")

    #global and target-specific exclude patterns
    pclp_generate_exclude_patterns("${PCLP_PROJECT_CFG_EXCLUDE_PATTERNS}")

    #record that this target is a registered PCLP analysis target
    pclp_register_target()

    next_stage()
endfunction()

# --------------------------------- PRIVATE FUNCTIONS ---------------------------------

#This function takes the given target and produces a list of all resolved dependencies, recursively.  It is intended to act iteratively
#across multiple cmake CLI invocations since different levels in the dependency hierarchy may include generator expressions that need
#to be resolved prior to determining that level's dependencies.
#   TARGET - input, the target whose (recursive, resolved) dependencies are being saved to file
#   DONE - output, TRUE when all the dependencies have been resolved, otherwise FALSE (in which case, additional invocations are necessary)
function(produce_resolved_target_dependencies_list TARGET DONE)
    set(NON_TARGETS "") #current (new) set of non-targets
    set(TARGETS "") #current (new) set of targets
    set(RECORDED_TARGETS "") #cumulative recorded targets
    set(RECORDED_NONTARGETS "") #cumulative recorded non-targets
    set(PENDINGS "") #non-targets pending resolution
    set(${DONE} FALSE PARENT_SCOPE)

    #filenames
    filefriendly_target_name(${TARGET} FILEFRIENDLY_TGT)
    set(CUMULATIVE_RES_DEPS_FILE "${CMAKE_BINARY_DIR}/pclp/cumulative_resolved_deps_${FILEFRIENDLY_TGT}")
    set(CUMULATIVE_NONTGT_DEPS_FILE "${CMAKE_BINARY_DIR}/pclp/cumulative_nontarget_deps_${FILEFRIENDLY_TGT}")
    set(PENDING_DEPS_FILE "${CMAKE_BINARY_DIR}/pclp/pending_deps_${FILEFRIENDLY_TGT}")

    if(EXISTS ${CUMULATIVE_RES_DEPS_FILE})
        file(READ ${CUMULATIVE_RES_DEPS_FILE} RECORDED_TARGETS)
    endif()

    if(EXISTS ${CUMULATIVE_NONTGT_DEPS_FILE})
        file(READ ${CUMULATIVE_NONTGT_DEPS_FILE} RECORDED_NONTARGETS)
    endif()

    if(EXISTS ${PENDING_DEPS_FILE})
        file(READ ${PENDING_DEPS_FILE} PENDINGS)
        file(REMOVE ${PENDING_DEPS_FILE})
    endif()

    if(NOT RECORDED_TARGETS) #if recorded targets list is empty this is the first time here, so start by getting the dependencies of the [PCLP-]TARGET argument
        if(NOT TARGET ${TARGET})
            list(APPEND NON_TARGETS ${TARGET})
        else()
            list(APPEND TARGETS ${TARGET})
        endif()
    else() #targets have already been recorded
        foreach(TGT ${RECORDED_TARGETS})
            get_target_dependencies(${TGT} DEPS)
            foreach(DEP ${DEPS})
                if(NOT TARGET ${DEP})
                    list(APPEND NON_TARGETS ${DEP})
                else()
                    list(APPEND TARGETS ${DEP})
                endif()
            endforeach()
        endforeach()
    endif()

    #process pending resolutions
    foreach(PENDING ${PENDINGS})
        if(TARGET ${PENDING})
            list(APPEND TARGETS ${PENDING})
        endif()
    endforeach()

    list(REMOVE_DUPLICATES NON_TARGETS)
    list(REMOVE_DUPLICATES TARGETS)

    set(NO_NEW_TARGETS FALSE)
    set(NO_NEW_NONTARGETS FALSE)
    sublist_entirely_contained_within_superlist("${TARGETS}" "${RECORDED_TARGETS}" NO_NEW_TARGETS)
    sublist_entirely_contained_within_superlist("${NON_TARGETS}" "${RECORDED_NONTARGETS}" NO_NEW_NONTARGETS)

    if(${NO_NEW_TARGETS} AND ${NO_NEW_NONTARGETS})
        #if no new targets or non-targets, onto the next stage!
        set(${DONE} TRUE PARENT_SCOPE)
        return()
    endif()

    #recorded targets
    list(APPEND RECORDED_TARGETS ${TARGETS})
    list(REMOVE_DUPLICATES RECORDED_TARGETS)
    file(WRITE ${CUMULATIVE_RES_DEPS_FILE} "${RECORDED_TARGETS}")

    #recorded non-targets
    list(APPEND RECORDED_NONTARGETS ${NON_TARGETS})
    list(REMOVE_DUPLICATES RECORDED_NONTARGETS)
    file(WRITE ${CUMULATIVE_NONTGT_DEPS_FILE} "${RECORDED_NONTARGETS}")

    #handle pending
    #here, really the only "non-targets" we care about are those that may actually be
    #a generator expression that eventually would resolve into a valid target with sources
    if(NON_TARGETS)
        handle_special_cases_generator_expressions(NON_TARGETS)
        list(REMOVE_DUPLICATES NON_TARGETS)
        file(GENERATE OUTPUT ${PENDING_DEPS_FILE} CONTENT "${NON_TARGETS}" TARGET ${TARGET})
    endif()
endfunction()

#This function produces a file system-friendly filename based on the given target name.  In this case, this means
#replacing characters found in generator expressions with underscores.
#   TARGET - input, the target whose name should be converted to be file system-friendly
#   FILEFRIENDLYNAME - output, the resulting file system-friendly target name
function(filefriendly_target_name TARGET FILEFRIENDLYNAME)
    set(CHARS_TO_REPLACE [[$]] [[<]] [[>]] [[:]])
    set(REPLACEMENT_CHAR "_")
    set(TMP ${TARGET})
    foreach(CHAR ${CHARS_TO_REPLACE})
        # Replace each occurrence of the identified characters with the replacement character
        string(REPLACE "${CHAR}" "${REPLACEMENT_CHAR}" TMP "${TMP}")
    endforeach()
    set(${FILEFRIENDLYNAME} ${TMP} PARENT_SCOPE)
endfunction()

#This function detects and handles all "special-case" generator expressions.  It iterates over each of the targets
#comprising the VALS input argument looking for any special cases, and handles each appropriately.  In the case of
#targets containing link context generator expressions, those are removed from the list entirely.  In the case of
#link feature generator expressions, those generator expressions are stripped and the resulting target list is
#split up into multiple entries added to VALS.
#   VALS - input & output, the list of targets to process
function(handle_special_cases_generator_expressions VALS)
    #LIMITATION - *very* simplistic parsing, with no support for nested generator expressions
    set(SPECIAL_CASES_TO_IGNORE "LINK_ONLY" "DEVICE_LINK" "HOST_LINK" "INSTALL_INTERFACE")
    set(SPECIAL_CASES ${SPECIAL_CASES_TO_IGNORE} "LINK_GROUP" "LINK_LIBRARY")

    #check for presense of any of the special case generator expressions in combination with nesting of generator expression(s)
    foreach(VAL IN LISTS ${VALS})
        #however... don't worry about values that *start* with the special cases to ignore since they should just be filtered out completely
        set(IGNORE_VAL FALSE)
        foreach(CASE IN LISTS SPECIAL_CASES_TO_IGNORE)
            string_starts_with(${VAL} "\$<${CASE}" RESULT)
            if(${RESULT})
                set(IGNORE_VAL TRUE)
                break()
            endif()
        endforeach()
        if(${IGNORE_VAL})
            continue()
        endif()

        string_contains_any("${VAL}" "${SPECIAL_CASES}" RESULT)
        if(${RESULT}) #special-case generator expression check
            number_of_char_instances_in_string(${VAL} [[$]] NUM_GEN_EXPRS)
            if(${NUM_GEN_EXPRS} GREATER 1) #nesting check
                message(WARNING "Nested generator expression detected (${VAL}), that also includes special-case expression(s) that would require complex custom parsing for correct handling.  This PCLP CMake wrap does not support nested generator expressions that contain special-case expressions that must be parsed.  Consider changing CMake to eliminate this scenario, or review PCLP output to ensure no files are missing from the analysis.")
            endif()
        endif()
    endforeach()

    #special case - ignore link context generator expressions completely
    list(FILTER ${VALS} EXCLUDE REGEX "LINK_ONLY")
    list(FILTER ${VALS} EXCLUDE REGEX "DEVICE_LINK")
    list(FILTER ${VALS} EXCLUDE REGEX "HOST_LINK")

    #special case - ignore generator expression syntax portion of link feature generator expressions (eg, $<LINK_GROUP:feature,library-list> to just library-list, where library list is lib1,lib2,lib3 ...)
    #and split result into multiple items
    set(TO_REMOVE "")
    set(TO_ADD "")
    foreach(VAL IN LISTS ${VALS})
        if((${VAL} MATCHES ".*LINK_GROUP.*") OR (${VAL} MATCHES ".*LINK_LIBRARY.*"))
            # "\$\<LINK_GROUP:(.*?,)(.*?)>" is the regex to match the LINK_GROUP gen. expr.
            string(REGEX REPLACE "^[^,]" "" MINUS_REGEX_PRE ${VAL})
            string(REGEX REPLACE ">" "" MINUS_REGEX ${MINUS_REGEX_PRE})
            tokenize("${MINUS_REGEX}" "," TGTS)
            list(APPEND TO_REMOVE ${VAL})
            list(APPEND TO_ADD ${TGTS})
        endif()
    endforeach()
    
    foreach(ITEM IN LISTS TO_REMOVE)
        list(REMOVE_ITEM ${VALS} ${ITEM})
    endforeach()
    list(APPEND ${VALS} ${TO_ADD})

    set(${VALS} "${${VALS}}" PARENT_SCOPE)
endfunction()

#This function reads the file representing the analysis target and all it's resolved dependencies and for each entry
#enables the EXPORT_COMPILE_COMMANDS target property.  The result of this is that at the end of CMake configuration
#a compilation database representing only those sources comprising the analysis target and it's resolved dependencies
#is produced.  This serves to scope the analysis and provide relevant configuration via this compilation database.
function(pclp_single_target_compilation_db)
    filefriendly_target_name(${PCLP_TARGET} FILEFRIENDLY_TGT)
    set(CUMULATIVE_RES_DEPS_FILE "${CMAKE_BINARY_DIR}/pclp/cumulative_resolved_deps_${FILEFRIENDLY_TGT}")
    file(READ ${CUMULATIVE_RES_DEPS_FILE} RECORDED_TARGETS)
    foreach(TGT ${RECORDED_TARGETS})
        pclp_export_compile_commands_for(${TGT})
    endforeach()
endfunction()

#This function enables the EXPORT_COMPILE_COMMANDS property for the given target.
#   TGT - input, target whose build command should be included in the compilation database.
function(pclp_export_compile_commands_for TGT)
    # Aliased targets do not support set_target_properties.
    # If the target is aliased, set the property on the underlying target.
    get_target_property(aliased ${TGT} ALIASED_TARGET)
    if(aliased)
        set_target_properties(${aliased} PROPERTIES EXPORT_COMPILE_COMMANDS ON)
    else()
        set_target_properties(${TGT} PROPERTIES EXPORT_COMPILE_COMMANDS ON)
    endif()
endfunction()

#This function takes the recorded unresolved library targets and produces a list of all resolved dependencies, recursively.  It is intended to act iteratively
#across multiple cmake CLI invocations since different levels in the dependency hierarchy may include generator expressions that need
#to be resolved prior to determining that level's dependencies.  Once each library target and it's dependencies are resolved, this function also
#processes them, recording source directories and public include directories.
#   TARGET - input, the target whose (recursive, resolved) dependencies are being saved to file
#   DONE - output, TRUE when all the dependencies have been resolved, otherwise FALSE (in which case, additional invocations are necessary)
function(pclp_process_library_targets DONE)
    set(${DONE} TRUE PARENT_SCOPE)

    #for the active registered target, get that target's library targets
    #and for each one, for that target and all it's recursive dependencies, *append* target_libraries.lnt with +libm derived from those dependencies' SOURCES (recursive)
    #and populate +libdir from those dependencies' PUBLIC include directories
    file(READ "${CMAKE_BINARY_DIR}/pclp/unresolved_library_targets" UNRESOLVED_LIBRARY_TARGETS)
    foreach(UNRESOLVED_LIBRARY_TARGET ${UNRESOLVED_LIBRARY_TARGETS})
        produce_resolved_target_dependencies_list(${UNRESOLVED_LIBRARY_TARGET} LIB_TGT_DONE)
        if(${LIB_TGT_DONE})
            filefriendly_target_name(${UNRESOLVED_LIBRARY_TARGET} FILEFRIENDLY_TGT)
            set(CUMULATIVE_RES_DEPS_FILE "${CMAKE_BINARY_DIR}/pclp/cumulative_resolved_deps_${FILEFRIENDLY_TGT}")
            file(READ ${CUMULATIVE_RES_DEPS_FILE} RECORDED_TARGETS)
            foreach(LIBRARY_TARGET_DEPENDENCY ${RECORDED_TARGETS})
                pclp_process_library_target("${LIBRARY_TARGET_DEPENDENCY}")
            endforeach()
        else()
            set(${DONE} FALSE PARENT_SCOPE)
        endif()
    endforeach()
endfunction()

#This function processes the given library target, recording to file it's source directories and include directories.
#   LIBRARY_TARGET - input, the library target to process
function(pclp_process_library_target LIBRARY_TARGET)
    set(LIB_SRCS "")
    set(LIB_INCS "")

    #check to see if this library target has already been processed (as part of a separate dependency path)
    set(PROCESSED_LIB_TGTS "")
    if(EXISTS "${CMAKE_BINARY_DIR}/pclp/processed_library_targets")
        file(READ "${CMAKE_BINARY_DIR}/pclp/processed_library_targets" PROCESSED_LIB_TGTS)
        if("${LIBRARY_TARGET}" IN_LIST PROCESSED_LIB_TGTS)
            return() #already processed! skip it this time around!
        endif()
    endif()
    list(APPEND PROCESSED_LIB_TGTS ${LIBRARY_TARGET})
    file(WRITE "${CMAKE_BINARY_DIR}/pclp/processed_library_targets" "${PROCESSED_LIB_TGTS}")

    #source files
    get_target_property(PUB_SOURCES "${LIBRARY_TARGET}" INTERFACE_SOURCES)
    get_target_property(PVT_SOURCES "${LIBRARY_TARGET}" SOURCES)
    list(APPEND LIB_SRCS ${PUB_SOURCES} ${PVT_SOURCES})

    #public include dirs
    get_target_property(LIB_INCS "${LIBRARY_TARGET}" INTERFACE_INCLUDE_DIRECTORIES)

    #prepare source files and include paths for resolution
    file(GENERATE OUTPUT "${CMAKE_BINARY_DIR}/pclp/target_library_sources_${LIBRARY_TARGET}" CONTENT "${LIB_SRCS}" TARGET ${LIBRARY_TARGET})
    file(GENERATE OUTPUT "${CMAKE_BINARY_DIR}/pclp/target_library_include_paths_${LIBRARY_TARGET}" CONTENT "${LIB_INCS}" TARGET ${LIBRARY_TARGET})

    #record this library target
    set(LIB_TGTS "")
    if(EXISTS "${CMAKE_BINARY_DIR}/pclp/resolved_library_targets")
        file(READ "${CMAKE_BINARY_DIR}/pclp/resolved_library_targets" LIB_TGTS)
    endif()
    list(APPEND LIB_TGTS ${LIBRARY_TARGET})
    file(WRITE "${CMAKE_BINARY_DIR}/pclp/resolved_library_targets" "${LIB_TGTS}")
endfunction()

#This function processes the recorded (to file) library target source directories and public include directories,
#and converts that information to +libm and +libdir options that PCLP understands.
function(pclp_process_lib_tgt_props)
    #at this point target_library_sources_${LIBRARY_TARGET} and target_library_include_paths_${LIBRARY_TARGET} files have been resolved

    set(TO_APPEND_TO_TARGET_LIBRARIES_FILE "")

    file(GLOB TGT_LIB_SRCS_FILES "${CMAKE_BINARY_DIR}/pclp/target_library_sources_*")
    file(GLOB TGT_LIB_INCS_FILES "${CMAKE_BINARY_DIR}/pclp/target_library_include_paths_*")

    #process sources
    foreach(TGT_LIB_SRCS_FILE IN LISTS TGT_LIB_SRCS_FILES)
        file(READ ${TGT_LIB_SRCS_FILE} SRCS)
        foreach(SOURCE IN LISTS SRCS)
            get_filename_component(EXTENSION "${SOURCE}" LAST_EXT)
            if(NOT ${EXTENSION} STREQUAL "")
                string(TOLOWER ${EXTENSION} EXTENSION)
                #only process C/C++ sources
                if(("${EXTENSION}" STREQUAL ".c") OR ("${EXTENSION}" STREQUAL ".cpp") OR ("${EXTENSION}" STREQUAL ".cxx") OR ("${EXTENSION}" STREQUAL ".cc"))
                    #we only care about the directory
                    get_filename_component(DIR "${SOURCE}" DIRECTORY)
                    list(APPEND TO_APPEND_TO_TARGET_LIBRARIES_FILE "+libm(${DIR}/*)")
                endif() 
            endif()
        endforeach()
    endforeach()

    #process include directories
    foreach(TGT_LIB_INCS_FILE IN LISTS TGT_LIB_INCS_FILES)
        file(READ ${TGT_LIB_INCS_FILE} INCLUDE_DIRS)
        foreach(DIR ${INCLUDE_DIRS})
            list(APPEND TO_APPEND_TO_TARGET_LIBRARIES_FILE "+libdir(${DIR})")
        endforeach()
    endforeach()

    list(REMOVE_DUPLICATES TO_APPEND_TO_TARGET_LIBRARIES_FILE)
    write_list_to_file(TO_APPEND_TO_TARGET_LIBRARIES_FILE "${CMAKE_BINARY_DIR}/pclp/target_libraries.lnt" APPEND)
endfunction()

#This function registers the current active analysis target, via creating a file in the file system.
function(pclp_register_target)
    #record within filesystem, for subsequent configurations to access
    file(TOUCH "${CMAKE_BINARY_DIR}/pclp/registered_pclp_target")
endfunction()

#This function can be called to determine of the current active target has been registered for analysis.
#   IS_REGISTERED - input, TRUE if the current active target is an analysis target, otherwise FALSE
function(is_pclp_target_registered IS_REGISTERED)
    set(${IS_REGISTERED} FALSE PARENT_SCOPE)
    if(EXISTS "${CMAKE_BINARY_DIR}/pclp/registered_pclp_target")
        set(${IS_REGISTERED} TRUE PARENT_SCOPE)
    endif()
endfunction()

#This function takes the given user-specified analysis options and analysis options files list and
#combines them into a single target_options.lnt file to serve as input to PCLP.
#   PCLP_ANALYSIS_OPTIONS - input, user-specified analysis options (e.g., -e123)
#   PCLP_ANALYSIS_OPTIONS_FILES - input, user-specified list of files containing analysis options
function(pclp_generate_target_options_file PCLP_ANALYSIS_OPTIONS PCLP_ANALYSIS_OPTIONS_FILES)
    set(ANALYSIS_OPTIONS_FILES_ABS "")
    foreach(ANALYSIS_OPTION_FILE ${PCLP_ANALYSIS_OPTIONS_FILES})
        get_filename_component(ANALYSIS_OPTION_FILE "${ANALYSIS_OPTION_FILE}" ABSOLUTE)
        list(APPEND ANALYSIS_OPTIONS_FILES_ABS "${ANALYSIS_OPTION_FILE}")
    endforeach()
    list(APPEND PCLP_ANALYSIS_OPTIONS "${ANALYSIS_OPTIONS_FILES_ABS}")
    write_list_to_file(PCLP_ANALYSIS_OPTIONS "${CMAKE_BINARY_DIR}/pclp/target_options.lnt" WRITE)
endfunction()

#This function takes the given user-specified library directories and library options files and
#combines them into a single target_libraries.lnt file to serve as input to PCLP.  Additionally, it takes
#the given list of "library targets" and records them to file for later processing
#   PCLP_LIBRARY_DIRS - input, user-specified library directories
#   PCLP_LIBRARY_OPTIONS_FILES - input, user-specified list of files containing library options
#   PCLP_LIBRARY_TARGETS - input, user-specified list of library targets to record to file
function(pclp_generate_target_libraries_file PCLP_LIBRARY_DIRS PCLP_LIBRARY_TARGETS PCLP_LIBRARY_OPTIONS_FILES)
    set(PCLP_LIBRARY_OPTIONS "")

    #populate target_libraries.lnt with PCLP_LIBRARY_DIRS
    set(LIBRARY_DIRS "")
    foreach(LIBRARY_DIR ${PCLP_LIBRARY_DIRS})
        list(APPEND PCLP_LIBRARY_OPTIONS "+libm(${LIBRARY_DIR})" "+libdir(${LIBRARY_DIR})")
    endforeach()

    #include reference to each PCLP_LIBRARY_OPTIONS_FILES item within target_libraries.lnt
    set(LIBRARY_OPTIONS_FILES_ABS "")
    foreach(LIBRARY_OPTION_FILE ${PCLP_LIBRARY_OPTIONS_FILES})
        get_filename_component(LIBRARY_OPTION_FILE "${LIBRARY_OPTION_FILE}" ABSOLUTE)
        list(APPEND LIBRARY_OPTIONS_FILES_ABS "${LIBRARY_OPTION_FILE}")
    endforeach()
    list(APPEND PCLP_LIBRARY_OPTIONS ${LIBRARY_OPTIONS_FILES_ABS})
    
    #write the cumulative list of library-related options to file
    write_list_to_file(PCLP_LIBRARY_OPTIONS "${CMAKE_BINARY_DIR}/pclp/target_libraries.lnt" WRITE)

    #write this TGT's PCLP_LIBRARY_TARGETS for later processing, once all targets are defined
    file(WRITE "${CMAKE_BINARY_DIR}/pclp/unresolved_library_targets" "${PCLP_LIBRARY_TARGETS}")
endfunction()

#This function takes the given user-specified exclude patterns and records them to file for later
#handling by the analysis scripting.  See PCLP manual description of project configuration exclude patterns for more information.
#   PCLP_PROJECT_CFG_EXCLUDE_PATTERNS - input, user-specified exclude patterns
function(pclp_generate_exclude_patterns PCLP_PROJECT_CFG_EXCLUDE_PATTERNS)
    file(READ "${CMAKE_SOURCE_DIR}/tools/pclp/global_configuration/global_exclude_patterns" PCLP_GLOBAL_EXCLUDE_PATTERNS)
    string(REPLACE "\n" ";" PCLP_GLOBAL_EXCLUDE_PATTERNS "${PCLP_GLOBAL_EXCLUDE_PATTERNS}")
    list(APPEND PCLP_PROJECT_CFG_EXCLUDE_PATTERNS ${PCLP_GLOBAL_EXCLUDE_PATTERNS})
    write_list_to_file(PCLP_PROJECT_CFG_EXCLUDE_PATTERNS "${CMAKE_BINARY_DIR}/pclp/cfg_exclude_patterns" WRITE)
endfunction()

#This function records to file all the targets that comprise the special-case 'all' target.
function(pclp_output_targets_in_all)
    if("${PCLP_TARGET}" STREQUAL "all")
        set(TGTS_IN_ALL "")
        get_all_targets(ALL_TARGETS)
        foreach(TGT ${ALL_TARGETS})
            get_target_property(TGT_EXCLUDED_FROM_ALL "${TGT}" EXCLUDE_FROM_ALL)
            if(NOT "${TGT_EXCLUDED_FROM_ALL}")
                list(APPEND TGTS_IN_ALL "${TGT}")
            endif()
        endforeach()
        write_list_to_file(TGTS_IN_ALL "${CMAKE_BINARY_DIR}/pclp/targets_in_all.txt" WRITE)
    endif()
endfunction()

#This function returns the currently active stage.
#   STAGE - output, currently active stage
function(get_stage STAGE)
    set(STAGE 0)
    if(EXISTS "${CMAKE_BINARY_DIR}/pclp/stage")
        file(READ "${CMAKE_BINARY_DIR}/pclp/stage" STAGE)
    else()
        file(WRITE "${CMAKE_BINARY_DIR}/pclp/stage" ${STAGE})
    endif()
    set(STAGE ${STAGE} PARENT_SCOPE)
endfunction()

#This function transitions to the next stage, recording to file for persistence across multiple CMake CLI invocations.
function(next_stage)
    get_stage(STAGE)
    MATH(EXPR STAGE "${STAGE}+1")
    file(WRITE "${CMAKE_BINARY_DIR}/pclp/stage" ${STAGE})
endfunction()

#This function skips any remaining stages and records to file.
function(skip_stages)
    file(WRITE "${CMAKE_BINARY_DIR}/pclp/stage" 99)
endfunction()