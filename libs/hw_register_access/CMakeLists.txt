add_library(hw_register_access INTERFACE)

include(CPM)

CPMAddPackage(
    NAME PortableBitfields
    GIT_REPOSITORY https://github.com/PlexusEP/PortableBitfields.git
    GIT_TAG v1.0.1
)

CPMAddPackage(
    NAME ETL
    GIT_REPOSITORY https://github.com/PlexusEP/etl.git
    GIT_TAG 20.40.0-1.0.0.plxs
)

target_include_directories(hw_register_access
    INTERFACE
        ${CMAKE_CURRENT_SOURCE_DIR}/public
)

target_link_libraries(hw_register_access
    INTERFACE
        jungles::bitfield
        etl::etl
)

if(PACKAGE_TESTS)
    add_subdirectory(test)
endif()
