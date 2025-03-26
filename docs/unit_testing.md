# Unit Testing

## Authoring Unit Tests

This template project sets up Google Test (including Google Mock) as the unit test framework.  EP recommends that tests be placed within `test` subfolders within individual library directories.  Both the `foo` and `bar` example libraries provide examples of unit tests.  See the contents of the `test` subdirectories within both of those library directories for details.  Use the VS Code task (previously mentioned [here](project_definition.md#adding-new-apps-and-libraries)) to add a new library that includes a basic unit test as a starting point.

## Running Unit Tests

EP recommends host-only unit tests.  Use the `gcc_debug_unit_tests` CMake configuration preset (which assumes Linux GCC as the toolchain) while using unit tests to develop and test software.  Several methods can be used to run these unit tests:

* Use the Testing Panel in VS Code to run individual or groups of tests
* Invoke CTest from the command line, e.g.: `pushd build/gcc_debug_unit_tests && ctest --schedule-random && popd`

!!! tip
    Sometimes, for VS Code to properly recognize unit tests, you may need to click the `Refresh Tests` button in the Testing Panel.

## Faking and Stubbing UUT Dependencies

This template provides hooks to facilitate unit testing library components.  Usage of the `add_library_testable_and_fakable` CMake function is recommended for libraries that are intended to be tested in isolation from other dependencies.  The example `bar` library illustrate usage of this function.  This function behaves similarly to the CMake `add_library` function in that it adds a new library target.  However, when a user selects the `gcc_debug_unit_tests` CMake configuration preset, it makes that library more "testable" and "fakable" by:

1. scoping all specified target include paths to be public
1. removing all sources from the target, but recording them within a variable named after the target (e.g., for `bar`, this is `${bar_SOURCES}`)

In this way, unit tests are able to access the library's private declarations as well as have the option to include library sources (typically the case for the UUT) or provide a fake implementation by specifying alternative sources (typically the case for UUT dependencies).  The `foo` unit test illustrates this latter concept.  There, a fake implementation of the `bar` dependency is provided (since bar is a direct dependency of the UUT).
