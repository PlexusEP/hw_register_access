if(PACKAGE_TESTS)
    #don't bother building applications if unit testing or not configured to build example apps
    return()
endif()

add_subdirectory(hw_register_access_cmsdk_apb_uart_example)
