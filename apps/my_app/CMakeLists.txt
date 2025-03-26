SET(CMAKE_FIND_PACKAGE_PREFER_CONFIG TRUE) #force CONFIG mode to avoid policy CMP0167 warning
find_package(Boost 1.83 REQUIRED COMPONENTS program_options)

add_executable(my_app)

target_sources(my_app
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/private/main.cpp
)

target_link_libraries(my_app PRIVATE foo ${Boost_LIBRARIES})

TARGET_GIT_VERSION_INIT(my_app)

pclp_single_target_configuration(
    my_app
)
