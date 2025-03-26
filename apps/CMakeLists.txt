if(PACKAGE_TESTS)
    #don't bother building applications if unit testing
    return()
endif()

add_subdirectory(my_app)
