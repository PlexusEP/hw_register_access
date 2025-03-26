# Project Definition

The template includes an example of how to use [CMake](https://cmake.org/) to configure and build projects using VS Code's [CMake Tools extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode.cmake-tools).  The template is configured by default for building with GCC, but can be easily extended to support other toolchains.

## Directory Structure

This project template consists of the following directories:  

`.devcontainer` : VS Code development container details  
`.vscode` : workspace-specific VS Code settings, tasks, etc.  
`apps` : project applications  
`docs` : MkDocs markdown-based workspace documentation  
`libs` : project libraries  
`tools` : collateral for various development tools such as CMake, PC-lint Plus, et. al.

Additionally, CMake creates a `build` directory during configuration, into which all build outputs are placed.  See the `CMake` and `CMake Tools` VS Code extension documentation for instructions on how to configure and build.  Similarly, MkDocs creates a `site` directory during documentation generation, into which all resulting static Web site files are placed.  See [Document Site Generation](#document-site-generation) for instructions on how to generate and preview documentation.  

This template provides an example of a componentized software project where applications are represented by code within the `apps` directory and libraries are represented by code within the `libs` directory. For illustration purposes the `my_app` sample application statically links to the `foo` library, which in turn links to it's sole dependency, `bar`.  Additionally, public include files for `foo` and `bar`  are contained within `public/foo` and `public/bar` so that external `#include` directive paths are all prefaced with the library name.  The intent is that projects use this model to provide their own libraries and applications and organize their project in a similar way.  

In addition to adding application and library components, other areas where projects are likely to customize or extend this template include adding custom VS Code workspace settings, tasks, and launch configurations, `tools`, `docs`, and CMake toolchain files within `tools/cmake/toolchains`.

## Adding New Apps and Libraries

This template comes pre-populated with an example application and example libraries.  These examples illustrate the recommended project and directory structure.  To add a new application consistent with this paradigm, use the `Application: Add` VS Code task.  Similarly, to add a new library consistent with this paradigm, use the `Library: Add` VS Code task.

## Package Management

This template uses [CMake Package Manager](https://github.com/cpm-cmake/CPM.cmake), or CPM, as the package manager.  For an example of CPM usage see `tools/cmake/gitversion.cmake`, where CPM is used to pull in the GitVersion dependency.

## Dependency Visualization

This template uses [Graphviz](https://graphviz.org/) in conjuntion with CMake to generate C/C++ dependency graphs.  To generate a basic dependency graph, perform a CMake configuration and build, with `graphviz` as the build target.  See the CMake and Graphviz documentation for additional details on customizing output.
