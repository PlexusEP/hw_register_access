# a custom target is used here, rather than, for example, a VS Code task
# to ensure that the cmake configuration options are taken into account
# when invoking GraphViz via CMake (ALMSCAD-2292)

add_custom_target(graphviz
    COMMAND ${CMAKE_COMMAND} "--graphviz=dependencies.dot" .
    COMMAND dot -Tpng dependencies.dot -o dependencies.png
    COMMAND code dependencies.png
    WORKING_DIRECTORY "${CMAKE_BINARY_DIR}"
)
