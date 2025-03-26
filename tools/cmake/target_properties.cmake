#public
function(get_all_targets out)
    set(targets)
    get_all_targets_recursive(targets ${CMAKE_SOURCE_DIR})
    set(${out} ${targets} PARENT_SCOPE)
endfunction()

#public
function(get_target_dependencies TARGET out)
    if(NOT TARGET ${TARGET})
        return()
    endif()

    get_target_property(TARGET_DEPS ${TARGET} LINK_LIBRARIES)
    get_target_property(TARGET_INT_DEPS ${TARGET} INTERFACE_LINK_LIBRARIES)

    if(TARGET_DEPS STREQUAL "TARGET_DEPS-NOTFOUND" AND TARGET_INT_DEPS STREQUAL "TARGET_INT_DEPS-NOTFOUND")
        return()
    endif()

    #See the note within https://cmake.org/cmake/help/latest/prop_tgt/LINK_LIBRARIES.html
    #that describes what ::@(directory-id);...;::@ expressions mean.  In this case, just ignore them
    #(both pre and post) since they are an internal CMake mechanism.
    list(FILTER TARGET_DEPS EXCLUDE REGEX "::@")
    list(FILTER TARGET_INT_DEPS EXCLUDE REGEX "::@")

    set(DEPS "")
    if(TARGET_DEPS STREQUAL "TARGET_DEPS-NOTFOUND")
        set(DEPS ${TARGET_INT_DEPS})
    elseif(TARGET_INT_DEPS STREQUAL "TARGET_INT_DEPS-NOTFOUND")
        set(DEPS ${TARGET_DEPS})
    else()
        list(APPEND DEPS ${TARGET_DEPS} ${TARGET_INT_DEPS})
        list(REMOVE_DUPLICATES DEPS)
    endif()

    set(${out} ${${out}} PARENT_SCOPE)
endfunction()

#public
#   only capable of recursing dependencies that are actually targets 
function(get_target_dependencies_recursive TARGET out)
    set(DEPS "")
    get_target_dependencies(${TARGET} DEPS)
    
    foreach(DEP ${DEPS})
        if("${DEP}" IN_LIST ${out})
            continue()
        endif()

        list(APPEND ${out} ${DEP})
        get_target_dependencies_recursive(${DEP} ${out})
    endforeach()

    set(${out} ${${out}} PARENT_SCOPE)
endfunction()

#private
macro(get_all_targets_recursive targets dir)
    get_property(subdirectories DIRECTORY ${dir} PROPERTY SUBDIRECTORIES)
    foreach(subdir ${subdirectories})
        get_all_targets_recursive(${targets} ${subdir})
    endforeach()

    get_property(current_targets DIRECTORY ${dir} PROPERTY BUILDSYSTEM_TARGETS)
    list(APPEND ${targets} ${current_targets})
endmacro()
