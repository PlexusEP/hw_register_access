add_library_testable_and_fakable(bar
    PRIVATE_SOURCES
        ${CMAKE_CURRENT_SOURCE_DIR}/private/bar.cpp
    PUBLIC_INCLUDE_DIRECTORIES
        ${CMAKE_CURRENT_SOURCE_DIR}/public
    PRIVATE_INCLUDE_DIRECTORIES
        ${CMAKE_CURRENT_SOURCE_DIR}/public/bar
)

if(PACKAGE_TESTS)
    add_subdirectory(test)
endif()
