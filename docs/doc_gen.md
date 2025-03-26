# Documentation Generation

## MkDocs Static Site Generation

This template project uses MkDocs to convert markdown documentation to a more usable static Web site.  Use the `MkDocs: Build` VS Code task to build the documentation, and the `MkDocs: Serve on localhost:8000` VS Code task to serve up a preview of the documentation on localhost, port 8000.  Typically, upon running this serve task VS Code will also prompt to open in a browser or preview in VS Code.

### Previous versions
By clicking the tab "Previous versions" you can access to older versions of this documentation. It is possible to add more versions by adding a tag with the format "docs-#.#.#" to the desired commit in master branch.

### UML diagrams
Here is an example of a UML diagram using PlantUML using the general layout of the software lifecycle processes.

```plantuml format="png"
scale 1.0

skinparam usecase {
    BackgroundColor Azure 
    BorderColor Black
    ArrowColor Black
}

skinparam rectangle {
    BackgroundColor Azure
    BorderColor Black
    ArrowColor Black
}

rectangle start
rectangle ReleaseToManufacturing

(start) --> (Initial Requirements and Software Architecture)
(Initial Requirements and Software Architecture) --> (Iterative Design Processes)
(Iterative Design Processes) --> (Verification Processes)
(Iterative Design Processes) --> (Iterative Design Processes)
(Verification Processes) --> (ReleaseToManufacturing)
(start) --> (Continuous Processes)
(Continuous Processes) --> (ReleaseToManufacturing)
``` 

### Alternative: Mermaid

Mermaid is a potential alternative to the MkDocs PlantUML plugin. For more information about Mermaid, see [this page](./unlisted/mermaid.md).

## Doxygen Code Documentation Generation

This template project uses Doxygen to convert code comments to documentation.  Use the `Doxygen: Build` VS Code task to build the documentation, and the `Doxygen: Serve` VS Code task to serve up a preview of the code documentation on localhost, port 8000.  Typically, upon running this serve task VS Code will also prompt to open in a browser or preview in VS Code.
