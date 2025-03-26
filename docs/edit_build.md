# Editing and Building

## Authoring Code

Several custom [PLXS-defined snippets](https://code.visualstudio.com/docs/editor/userdefinedsnippets) are provided with this template.  See `.vscode/cpp.code-snippets` for details regarding these snippets, including prefix for each snippet.  To use any of these snippets, start typing the desired prefix and select the appropriate auto-complete option.

## Application Versioning

This template project utilizes the [gitversion](https://github.com/smessmer/gitversion) tool to generate version information from the Git repository commit SHA, tag/branch name, as well as additional info such as if the repository is clean.  This is accomplished during the CMake configuration step generating the `build/messmer_gitversion/gitversion/version.h` file.  The CMake step also adds the include path to the generated header file.  Example of usage is currently in `my_app/main.cpp`.

For further information see the readme file and other documentation within the [gitversion GitHub repository](https://github.com/smessmer/gitversion).

## Building the Example App

This template comes pre-populated with an example application, `my_app`.  To build this application (and really, any component) perform the following steps:

1. Use the CMake Panel to select a Configure Preset that represents the toolchain to use for the build, specific to the target on which you'd like to run your application.  Configuration Presets are defined within the `CMakePresets.json` file in the root of the workspace.  In the case of `my_app`, select the `gcc_debug` configuration preset.
1. Run the `CMake: Build` VS Code command to automatically perform a CMake configuration and compile and link the application.

Note that at any time you can select a different CMake configuration, or scope the build by using the CMake Panel to select a build preset and/or a build target.

## Code Indexing

This template uses [clangd](https://clangd.llvm.org/) as the code indexing engine.  This tool leverages the compilation database (`compile_commands.json`) within the root of the workspace to determine include paths, etc.  _Note that this means that code indexing is limited in scope to the currently selected CMake build target._

Clangd also queries the compiler to discover built-in paths to things like standard library headers.  The `--query-driver` argument to `clangd` can be updated to point to additional compilers whenever new toolchains are added.  Note that per clangd documentation this is simply "whitelisting" that compiler, enabling clangd to query it.  Wildcards can be used here.  See the online clangd documentation for more details.

Any problems with code indexing can be debugged by observing `clangd` output in VS Code's Output panel.
