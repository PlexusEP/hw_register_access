option(PACKAGE_TESTS "Build the unit tests" OFF)
set(GTEST_ADDITIONAL_LIBS "" CACHE STRING "Additional libraries to link to all UUTs")

#public
# 
#valid TYPEs: STATIC, SHARED, OBJECT, MODULE, INTERFACE
#does not support IMPORTED or ALIAS libraries
function(add_library_testable_and_fakable TGT)
    set(optionArgs "EXCLUDE_FROM_ALL")
    set(oneValueArgs "TYPE")
    set(multiValueArgs 
        PUBLIC_SOURCES
        PRIVATE_SOURCES
        INTERFACE_SOURCES
        PUBLIC_INCLUDE_DIRECTORIES
        PRIVATE_INCLUDE_DIRECTORIES
        INTERFACE_INCLUDE_DIRECTORIES
        PUBLIC_LINK_LIBRARIES
        PRIVATE_LINK_LIBRARIES
        INTERFACE_LINK_LIBRARIES)
    cmake_parse_arguments(UT_LIB "${optionArgs}" "$oneValueArgs}" "${multiValueArgs}" ${ARGN})

    if(NOT DEFINED UT_LIB_TYPE)
        set(UT_LIB_TYPE STATIC) #default to STATIC type
    endif()

    if(PACKAGE_TESTS)
        #convert all libs to INTERFACE libs for purposes of unit testing
        add_library(${TGT} INTERFACE)

        #for unit tests, rather than adding sources to the target, capture *all* sources to a global variable that can then
        #be optionally used to populate a unit test target later on.  This facilitates faking/stubbing through alternative sources.
        set(${TGT}_SOURCES ${UT_LIB_PUBLIC_SOURCES} ${UT_LIB_PRIVATE_SOURCES} ${UT_LIB_INTERFACE_SOURCES} CACHE INTERNAL "optional sources for the ${TGT} target")

        #for unit tests, provide paths to *all* includes, including private
        target_include_directories(${TGT}
            INTERFACE
                ${UT_LIB_PUBLIC_INCLUDE_DIRECTORIES}
                ${UT_LIB_PRIVATE_INCLUDE_DIRECTORIES}
                ${UT_LIB_INTERFACE_INCLUDE_DIRECTORIES}
        )

        target_link_libraries(${TGT}
            INTERFACE
                ${UT_LIB_PUBLIC_LINK_LIBRARIES}
                ${UT_LIB_PRIVATE_LINK_LIBRARIES}
                ${UT_LIB_INTERFACE_LINK_LIBRARIES}
        )
    else()
        if(UT_LIB_EXCLUDE_FROM_ALL)
            add_library(${TGT} ${UT_LIB_TYPE} EXCLUDE_FROM_ALL)
        else()
            add_library(${TGT} ${UT_LIB_TYPE})
        endif()

        target_sources(${TGT} 
            PUBLIC ${UT_LIB_PUBLIC_SOURCES}
            PRIVATE ${UT_LIB_PRIVATE_SOURCES}
            INTERFACE ${UT_LIB_INTERFACE_SOURCES}
        )

        target_include_directories(${TGT}
            PUBLIC ${UT_LIB_PUBLIC_INCLUDE_DIRECTORIES}
            PRIVATE ${UT_LIB_PRIVATE_INCLUDE_DIRECTORIES}
            INTERFACE ${UT_LIB_INTERFACE_INCLUDE_DIRECTORIES}
        )

        target_link_libraries(${TGT}
            PUBLIC ${UT_LIB_PUBLIC_LINK_LIBRARIES}
            PRIVATE ${UT_LIB_PRIVATE_LINK_LIBRARIES}
            INTERFACE ${UT_LIB_INTERFACE_LINK_LIBRARIES}
        )
    endif()
endfunction()

if(NOT PACKAGE_TESTS)
    return()
endif()

include(CPM)

CPMAddPackage(
    NAME googletest
    URL https://github.com/google/googletest/archive/refs/tags/v1.15.2.zip)

enable_testing()
include(GoogleTest)

if (NOT GTEST_MAIN_TARGET)
    set(GTEST_MAIN_TARGET "gmock_main")
endif()

#public
macro(register_test target)
    target_link_libraries(${target} PRIVATE gtest gmock ${GTEST_MAIN_TARGET} $<$<BOOL:${GTEST_ADDITIONAL_LIBS}>:${GTEST_ADDITIONAL_LIBS}>)
    gtest_discover_tests(${target} WORKING_DIRECTORY ${CMAKE_RUNTIME_OUTPUT_DIRECTORY})
endmacro()
