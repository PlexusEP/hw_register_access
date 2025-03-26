# C++ Project Template

## Features

This [C++ project template](https://eng.plexus.com/git/projects/EP/repos/cpp-project-template/browse) provides a starting point for C++-based project codebases.  It represents several best practices related to containerized software development, project organization, unit testing, static analysis, and code styling.  This _[Modern Cpp Starter](https://github.com/TheLartians/ModernCppStarter)_ was the inspiration for this more Plexus-specific project. This template provides the following features:

* Containerized, controlled, extensible, and versioned development ecosystem
* Defining a C/C++ project, including specifying dependencies and visualizing dependency graphs
* Editing and building
* Debugging
* Unit Testing
* Static Analysis
* Documentation Generation
* Code Styling

## NPS Validation

NPS validation for the CPP Development Ecosystem which includes this project template as well as the corresponding Docker image (see [Containerized Development](#containerized-development)) can be found within Plexus Agile.

* v1.1.0 - VCO02111

## Opening This Template Project

See the [Infrastructure](infrastructure.md) section for details on how to configure your host environment prior to opening this template project or any project based on it.

To start, cllone your project-specific repo of this C++ template project and open that workspace within VS Code.  When prompted select the `Reopen in container` option.  Alternatively you may also select the blue arrow button in the lower-left corner of the screen and select `Reopen in container` or run the `Dev Containers: Reopen in Container` VS Code command.

!!! note
    The first time the template project is opened from within the container, the container image will download.  This can take several minutes to complete.  VS Code does provide a `show log` option during this process.  Also, because the Docker registry is not yet externally available, users need to be connected to the Plexus network during the image download process.

## Alternatives to Standard Options

As mentioned in the [Features section](#features), this project template defines a standard set of tools and configurations that represent current recommended best practices.  However, there may be times when a project team makes a decision to try something different.  So long as it is intentional and controlled, this kind of thing is encouraged because it represents the primary way this standard work is improved over time.  When sufficient evidence exists (likely due to project usage) that an alternative is an improvement over existing recommended best practices, those best practices (in the form of this C++ project template) will be updated.  Various sections within this documentation mention potential alternatives to these standard options.

## Issue Tracking

EP uses Jira to track known issues with this project template and the associated ecosystem.  These boards are not intended to duplicate documentation of issues described elsewhere (e.g. tool release notes), but instead track issues specific to this template's usage, or that are otherwise undocumented.

Some tools have dedicated issue tracking boards while others are lumped into boards based on functional category.  This documentation provides links to the various issue tracking boards, where applicable.

For a list of known issues related to this template and VS Code, see [this Jira board](https://eng.plexus.com/jira/secure/RapidBoard.jspa?rapidView=2749&projectKey=PLXSEP).
