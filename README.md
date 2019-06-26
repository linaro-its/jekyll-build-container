# jekyll-build-container
A Docker container used by Linaro's web site build process.

The container isolates the building of Linaro's Jekyll-based web sites. This avoids needing to install directly on the host the numerous packages used when building the sites.

In addition to the notes below, more documentation can be found on the [wiki](https://github.com/linaro-its/jekyll-build-container/wiki).

## Building
### Prerequisites

* An operating system capable of running [Docker](https://www.docker.com)
* Enough free RAM and disc space

Building has been tested with [Docker Community Edition](https://www.docker.com/community-edition#/download) under [Arch Linux](https://archlinux.org) and [Ubuntu](https://www.ubuntu.com).

### Building
Build the container in the usual way, e.g.

`docker build --rm -t "linaroits/jekyllsitebuild:<tag>" .`

**Important:** If developing a variant of this container, e.g. to add a new package, use a personal tag reference and then specify that tag when running the site building script, e.g.:

`JEKYLLSITEBUILD="personaltag" ./build-site.sh`

If you omit `<tag>`, Docker will default to tagging the container as `latest` which could cause confusion if testing local changes. For that reason, Linaro-provided versions of the jekyllsitebuild container will display the Bamboo build reference at the start of the scripts being run, e.g.:

```
Container built by bamboo.linaro.org: CON-JBC-JOB1-43 20190622-1009
...
```

Built containers can also be found on [Docker Hub](https://hub.docker.com/r/linaroits/jekyllsitebuild/tags/) for your convenience.

### Assumptions
Since Docker allows host directories to be volume-mounted into the container, this allows the scripts to be simplified because it is *assumed* that the source directory is mounted onto /srv/source and the output directory is mounted onto /srv/output.
