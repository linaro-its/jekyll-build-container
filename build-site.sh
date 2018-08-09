#!/bin/bash
#
# If GEM_HOME isn't set, set a default
if [ -z "$GEM_HOME" ]; then
    export GEM_HOME=./.gems
fi
#
# Make sure the gems directory exists
if [ ! -d "$GEM_HOME" ]; then
    mkdir $GEM_HOME
fi
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
if [ -z "$SOURCE_DIR" ]; then
    export SOURCE_DIR=./source_dir
fi
if [ -z "$DEST_DIR" ]; then
    export DEST_DIR=./dest_dir
fi
if [ ! -d "$SOURCE_DIR" ]; then
    echo "Cannot find source directory: $SOURCE_DIR"
    exit 1
fi
if [ ! -d "$DEST_DIR" ]; then
    echo "Cannot find destination directory: $DEST_DIR"
    exit 1
fi
#
# Default to building; allows override to serving.
if [ -z "$JEKYLL_ACTION" ]; then
    export JEKYLL_ACTION="build"
fi
#
# Install the bundle
bundle Install
#
# Build the site
bundle exec jekyll "$JEKYLL_ACTION" --source "$SOURCE_DIR" --destination "$DEST_DIR" --config "$JEKYLL_CONFIG" JEKYLL_ENV="$JEKYLL_ENV"
