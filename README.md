# jekyll-build-container
A Docker container used by Linaro's web site build process.

The container isolates the building of Linaro's Jekyll-based web sites. This avoids needing to install directly on the host the numerous packages used when building the sites.

In addition to the notes below, more documentation can be found on the [wiki](https://github.com/linaro-its/jekyll-build-container/wiki).

## Building
### Prerequisites

* An operating system capable of running [Docker](https://www.docker.com)
* Enough free RAM and disc space

Building has been tested with [Docker Community Edition](https://www.docker.com/community-edition#/download) under [Arch Linux](https://archlinux.org), [Ubuntu 17.10](https://www.ubuntu.com) and [Windows 10](https://www.microsoft.com/windows).

### Building
Build the container in the usual way, e.g.

`docker build --rm -t "linaroits/jekyllsitebuild" .`

Built containers can also be found on [Docker Hub](https://hub.docker.com/r/linaroits/jekyllsitebuild/tags/) for your convenience.

### Assumptions
Since Docker allows host directories to be volume-mounted into the container, this allows the scripts to be simplified because it is *assumed* that the source directory is mounted onto /srv/source and the output directory is mounted onto /srv/output.
