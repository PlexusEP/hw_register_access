add_executable(test_foo)

target_sources(test_foo
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/test_foo.cpp
        bar_fake.cpp #example of providing a fake dependency implementation
)

target_link_libraries(test_foo
    PRIVATE
        foo
        
        #perhaps redundant with the linking 'foo' already does, but this gives
        #this test suite which provides a fake 'bar' impl. access to the necessary include paths
        bar 
)

register_test(test_foo)
