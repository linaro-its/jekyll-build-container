# jekyll-build-container
A Docker container used by Linaro's web site build process.

The container isolates the building of Linaro's Jekyll-based web sites. This avoids needing to install directly on the host the numerous packages used when building the sites.

## Building
### Prerequisites

* An operating system capable of running [Docker](https://www.docker.com)
* Enough free RAM and disc space

Building has been tested with [Docker Community Edition](https://www.docker.com/community-edition#/download) under [Arch Linux](https://archlinux.org), [Ubuntu 17.10](https://www.ubuntu.com) and [Windows 10](https://www.microsoft.com/windows).

### Building
Build the container in the usual way, e.g.

`docker build --rm -t "linaroits/jekyllsitebuild" .`

Built containers can also be found on [Docker Hub](https://hub.docker.com/r/linaroits/jekyllsitebuild/tags/) for your convenience.

## Usage Notes
Note that, by itself, the container doesn't do much. The repositories for each site will contain the necessary scripts to build, test and serve the site. Those scripts do, though, use a build script included in this container.

Linaro's Jekyll sites use a number of Gems in order to build. By default, the build process will install those gems in `<repo dir>/.gems`. If you want to override that (for example if you are building multiple sites and want to conserve space), set `GEM_HOME` before running any of the scripts in the web site repo.

Before building the site, the environment variable `JEKYLL_ENV` needs to be set to `staging` or `production` to build the appropriate site. The scripts in the web site repo will default this to `staging` if you do not override it before running the scripts.

By default, the build process expects to be running in the directory of the repo, with the repo containing two directories: source_dir and dest_dir. If that is not the case, or if you want the build process to look elsewhere for the directories, you can set `SOURCE_DIR` and `DEST_DIR` before starting the build process. Please note, though, that the values for the variables must be relative to the container's directory structure and not the host's.

## PRs and Issues
Issues with the Dockerfile and any of the scripts stored in the Dockerfile should be raised [here](https://github.com/linaro-its/jekyll-build-container/issues/new). If a site isn't building, please raise an issue on the repo of the site concerned.

### Windows 10 notes
If you encounter the error `driver failed programming external connectivity on endpoint`, please restart Docker on your system and try again. This appears to be related to the way Fast Start currently works. Source: [StackOverflow](https://stackoverflow.com/questions/44414130/docker-on-windows-10-driver-failed-programming-external-connectivity-on-endpoin)

The message `Don't run Bundler as root` can be ignored. This is a consequence of how the Linux environment is being used on top of the Windows-hosted site repo directory.
