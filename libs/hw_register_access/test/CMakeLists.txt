add_executable(test_hw_register_access)

target_sources(test_hw_register_access
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/test_hw_register_access.cpp
)

target_link_libraries(test_hw_register_access
    PRIVATE
        hw_register_access
)

register_test(test_hw_register_access)
