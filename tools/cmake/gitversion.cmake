include(CPM)

CPMAddPackage(
    NAME gitversion
    GIT_REPOSITORY https://github.com/PlexusEP/gitversion.git
    GIT_TAG PlexusEP_1.0)
    
include(${gitversion_SOURCE_DIR}/cmake.cmake)
