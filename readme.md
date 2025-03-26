# TODO Library

## Summary

TODO - This library is intended to...

## Example Application(s)

TODO - The following applications within this repository provide usage examples for the TODO Library ...

## Incorporating Into Your Project

CMake Package Manager (CPM) is recommended to incorporate this Hardware Register Access Library.  Use whatever `GIT_TAG` option is appropriate for your project.

```
include(CPM)

CPMAddPackage(
    NAME TODO
    GIT_REPOSITORY https://github.com/PlexusEP/TODO.git
    GIT_TAG v1.0.0
)

target_link_libraries(your_target
    PRIVATE
        TODO
)
```

... TODO include any additional instructions such as headers to include, etc. ...

## Updating This Library

When updating this library, make sure it remains lint-free, conforms to style guidelines, etc.  To facilitate such updates, the development environment containing all the necessary tools has been containerized.  See the [C++ Project Template documentation](https://eng.plexus.com/git/pages/EP/cpp-project-template/site/browse/) for more information about containerization and the workflows available for performing various tasks using this environment.

Set the `STANDALONE_LIB_DEV` CMake option to `ON` when making updates to unlock these workflows.  This option is off by default in order to make sure the CMake for this library doesn't conflict or contradict higher-level CMake when pulled into a project as a dependency.
