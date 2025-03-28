add_executable(hw_register_access_cmsdk_apb_uart_example)

target_sources(hw_register_access_cmsdk_apb_uart_example
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/private/main.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/private/qemu_debug_uart.cpp
)

target_link_libraries(hw_register_access_cmsdk_apb_uart_example
    PRIVATE
        hw_register_access
)

pclp_single_target_configuration(
    hw_register_access_cmsdk_apb_uart_example
)
