# jekyll-build-container
A Docker container used by Linaro's web site build process.

The container isolates the building of Linaro's Jekyll-based web sites. This avoids needing to install directly on the host the numerous packages used when building the sites.

Build the container in the usual way, e.g.

`docker build --rm -t "linaroits/jekyllsitebuild" .`

Note that, by itself, the container doesn't do much. The repositories for each site will contain the necessary scripts to build, test and serve the site. Those scripts do, though, use a build script included in this container.

Linaro's Jekyll sites use a number of Gems in order to build. By default, the build process will install those gems in `<repo dir>/.gems`. If you want to override that, set GEM_HOME before running any of the scripts in the web site repo.

Before building the site, the environment variable `JEKYLL_ENV` needs to be set to `staging` or `production` to build the appropriate site.

By default, the build process expects to be running in the directory of the repo, with the repo containing two directories: source_dir and dest_dir. If that is not the case, or if you want the build process to look elsewhere for the directories, you can set `SOURCE_DIR` and `DEST_DIR` before starting the build process. Please note, though, that the values for the variables must be relative to the container's directory structure and not the host's.
