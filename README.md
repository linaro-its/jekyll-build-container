# jekyll-build-container

A Docker container used by Linaro's web site build process.

The container isolates the building of Linaro's Jekyll-based web sites. This avoids needing to install directly on the host the numerous packages used when building the sites. The container includes all of the Ruby gems used across the web sites, which is why it is critical that changes made to Gemfiles in any of the website repositories must be matched with a corresponding change to the gems referenced in the Dockerfile. Failure to do so could result in build failure on Linaro's Bamboo build service.

In addition to the notes below, more documentation can be found on the [wiki](https://github.com/linaro-its/jekyll-build-container/wiki).

## Building

### Prerequisites

* An operating system capable of running [Docker](https://www.docker.com)
* Enough free RAM and disc space

Building has been tested with [Docker Community Edition](https://www.docker.com/community-edition#/download) under [Arch Linux](https://archlinux.org), [Ubuntu](https://www.ubuntu.com) and [Windows 10](https://www.microsoft.com).

### Building the container

Build the container in the usual way, e.g.

`docker build --rm -t "linaroits/jekyllsitebuild:<tag>" .`

**Important:** If developing a variant of this container, e.g. to add a new package, use a personal tag reference and then specify that tag when running the site building script, e.g.:

`JEKYLLSITEBUILD="personaltag" ./build-site.sh`

If you omit `<tag>`, Docker will default to tagging the container as `latest` which could cause confusion if testing local changes. For that reason, Linaro-provided versions of the `jekyllsitebuild` container will display the GitHub build reference at the start of the scripts being run, e.g.:

```text
Container built by GitHub. Build reference: 4890b2c
...
```

The build reference is the commit SHA for the repository.

If the system running the build has access to the Internet, it will check Docker Hub to see if the latest image is being used and warn if it isn't.

Built containers can also be found on [Docker Hub](https://hub.docker.com/r/linaroits/jekyllsitebuild/tags/) for your convenience.
