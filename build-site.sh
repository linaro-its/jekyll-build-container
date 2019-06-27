#!/bin/bash
#
# If possible, show which container version this is
if [ -f "/usr/local/etc/bamboo-build.txt" ]; then
    value=$(</usr/local/etc/bamboo-build.txt)
    if [ ! -z "$value" ]; then
        echo "$value"
    fi
fi
#
# Check we've got defined vars
if [ -z "$JEKYLL_ENV" ]; then
    echo "JEKYLL_ENV needs to be set"
    exit 1
fi
if [ "$JEKYLL_ENV" != "staging" ] && [ "$JEKYLL_ENV" != "production" ]; then
    echo "JEKYLL_ENV must be set to 'staging' or 'production'"
    exit 1
fi
#
# Check that we've got a source dir. We now always build the site inside the
# source directory.
if [ ! -d "/srv/source" ]; then
    echo "Cannot find source directory"
    exit 1
fi
if [ ! -f "/srv/source/Gemfile" ]; then
    echo "Cannot find Gemfile in source directory"
    exit 1
fi
#
# Override $HOME to point at the volume-mounted directory. This is needed
# because Bundle writes to a .bundle directory inside the user's home
# directory.
export HOME=/srv/source
#
# Default to building; allows override to serving.
if [ -z "$JEKYLL_ACTION" ]; then
    export JEKYLL_ACTION="build"
fi
if [ "$JEKYLL_ACTION" == "serve" ]; then
    HOST="-H0.0.0.0"
else
    HOST=""
fi
#
# Change to the source directory rather than telling "bundle install"
# where to find the Gemfile because Jekyll expects it to be in the
# current directory.
cd "/srv/source" || exit
#
# Build the site
echo "Building site"
bundle exec jekyll "$JEKYLL_ACTION" "$HOST" --trace --config "_config.yml,_config-$JEKYLL_ENV.yml" JEKYLL_ENV="$JEKYLL_ENV"
