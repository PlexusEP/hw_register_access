add_executable(test_bar)

target_sources(test_bar
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/test_bar.cpp
        ${bar_SOURCES}
)

target_link_libraries(test_bar
    PRIVATE
        bar
)

register_test(test_bar)
