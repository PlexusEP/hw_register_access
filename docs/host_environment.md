# Host Environment

## Dependencies

This project template depends on the following to be installed into the host environment:

* Docker  
    * The Docker images that are used are pulled from our JFrog Docker registry - see [here](https://eng.plexus.com/git/pages/EP/devtools/site/browse/version_control/binary/rt/) for instruction on how to get set up.
* VS Code including `Remote - Containers` Extension

For more information about host environments that satisfy these base dependencies, see [Pre-Configured Host Environments](#pre-configured-host-environments).

All other dependencies are included in the Docker development image.  See [Containerized Development](#containerized-development) for more details about this.  Although it is not recommended, projects may choose to forgo containerization of the development environment.  In these cases any project template functionality that projects intend to leverage needs to be supported with native installations of the corresponding tools.

## Local Host

Users may choose to import a base Ubuntu VM and run this project template within that environment.  For more information about this VM, see this [link](https://eng.plexus.com/git/pages/EP/devtools/site/browse/development_environment/host/linux/linux_host/).

### Issue Tracking

For a list of known issues related to WSL/2, see [this Jira board](https://eng.plexus.com/jira/secure/RapidBoard.jspa?rapidView=2750&projectKey=PLXSEP).
For a list of known issues related to VMWare, see [this Jira board](https://eng.plexus.com/jira/secure/RapidBoard.jspa?rapidView=2748&projectKey=PLXSEP).

## Remote Host

Facilitated by the containerized nature of this development environment, developers may choose to host this container on a high-performing remote host.  Paired with VS Code `Remote - Containers`, the VS Code `Remote - SSH` extension enables this powerful workflow.  See this [link](https://eng.plexus.com/git/pages/EP/devtools/site/browse/hpc_backends/remote/) for more information about this workflow.

## Containerized Development

### Development Ecosystem Container

VS Code recognizes the `.devcontainer/devcontainer.json` file.  When it sees this file it knows the workspace is intended to be used within a development container.  This JSON file describes for VS Code how to download the appropriate Docker image and instantiate a container based on that image.  This Docker image defines the ecosystem necessary for C++ application development.  See the `Remote - Containers` VS Code extension for more details.  

The Docker image defining the C++ development ecosystem is defined [here](https://eng.plexus.com/git/projects/EP/repos/docker-plxs-cpp/browse).  However, when required, projects are encouraged to work with EP to enhance this image with any other tools their specific target(s) may require.  In those cases, EP will create a project-specific repository containing a custom Dockerfile (and any other context needed to build the project image).  In most cases, project-specific Docker images should baseline from the latest stock C++ development ecosystem image.

If your project does require an extended image don't forget to assign a project-specific tag and work with EP to push the image to a remote Docker registry.  Lastly, you'll need to update `.devcontainer/devcontainer.json` to point to this extended, project-specific image.

### Containerized Support Applications

In some cases it makes more sense to containerize an individual application (and it's dependencies) rather than incorporate it into a project's development ecosystem image.  This template also support launching these types of individually containerized "support applications".  As an example, the VS Code task `Containerized GUI Example: Launch` can be used to launch an individually containerized application.

### Issue Tracking

For a list of known issues related to Docker, see [this Jira board](https://eng.plexus.com/jira/secure/RapidBoard.jspa?rapidView=2744&projectKey=PLXSEP).
