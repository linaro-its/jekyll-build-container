#!/bin/bash
#
# Check we've got defined vars
if [ -z "$JEKYLL_CONFIG" ]; then
    echo "JEKYLL_CONFIG needs to be set"
    exit 1
fi
if [ -z "$JEKYLL_ENV" ]; then
    echo "JEKYLL_ENV needs to be set"
    exit 1
fi
if [ "$JEKYLL_ENV" != "staging" ] && [ "$JEKYLL_ENV" != "production" ]; then
    echo "JEKYLL_ENV must be set to 'staging' or 'production'"
    exit 1
fi
#
# Check that we've got a source dir and a dest dir
if [ ! -d "/srv/source" ]; then
    echo "Cannot find source directory"
    exit 1
fi
if [ ! -f "/srv/source/Gemfile" ]; then
    echo "Cannot find Gemfile in source directory"
    exit 1
fi
if [ ! -d "/srv/output" ]; then
    echo "Cannot find output directory"
    exit 1
fi
#
# If GEM_HOME isn't set, set a default
if [ -z "$GEM_HOME" ]; then
    GEM_HOME=$(pwd)/.gems
    export GEM_HOME
fi
#
# Make sure the gems directory exists
if [ ! -d "$GEM_HOME" ]; then
    mkdir "$GEM_HOME"
fi
#
# Make sure that the user's home directory exists, to avoid bundler
# complaining
if [ ! -d "$HOME" ]; then
    mkdir -P "$HOME"
fi
#
# Default to building; allows override to serving.
if [ -z "$JEKYLL_ACTION" ]; then
    export JEKYLL_ACTION="build"
fi
if [ "$JEKYLL_ACTION" == "serve" ]; then
    HOST="-H 0.0.0.0"
else
    HOST=""
fi
#
# Change to the source directory rather than telling "bundle install"
# where to find the Gemfile because Jekyll expects it to be in the
# current directory.
cd "/srv/source" || exit
# Install the bundle
echo "Installing gems"
bundle install
#
# Build the site
echo "bundle exec jekyll $JEKYLL_ACTION $HOST --source /srv/source --destination /srv/output --config $JEKYLL_CONFIG JEKYLL_ENV=$JEKYLL_ENV"
bundle exec jekyll "$JEKYLL_ACTION" "$HOST" --source /srv/source --destination /srv/output --config "$JEKYLL_CONFIG" JEKYLL_ENV="$JEKYLL_ENV"
