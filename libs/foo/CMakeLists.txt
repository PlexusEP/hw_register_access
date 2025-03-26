add_library(foo)

target_sources(foo
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/private/foo.cpp
)

target_include_directories(foo
    PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}/public
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/public/foo
)

target_link_libraries(foo
    PRIVATE
        bar
)

if(PACKAGE_TESTS)
    add_subdirectory(test)
endif()
