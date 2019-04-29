#!/bin/bash
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
    SOURCE_DIR=$(pwd)/source_dir
    export SOURCE_DIR
fi
if [ -z "$DEST_DIR" ]; then
    DEST_DIR=$(pwd)/dest_dir
    export DEST_DIR
fi
if [ ! -d "$SOURCE_DIR" ]; then
    echo "Cannot find source directory: $SOURCE_DIR"
    exit 1
fi
if [ ! -f "$SOURCE_DIR/Gemfile" ]; then
    echo "Cannot find Gemfile in source directory: $SOURCE_DIR"
    exit 1
fi
if [ ! -d "$DEST_DIR" ]; then
    echo "Cannot find destination directory: $DEST_DIR"
    exit 1
fi
#
# Change to the source directory rather than telling "bundle install"
# where to find the Gemfile because Jekyll expects it to be in the
# current directory.
cd "$SOURCE_DIR" || exit
#
# Build the site
echo "bundle exec jekyll serve -H 127.0.0.1 --skip-initial-build --source $SOURCE_DIR --destination $DEST_DIR --config $JEKYLL_CONFIG JEKYLL_ENV=$JEKYLL_ENV"
bundle exec jekyll serve -H 127.0.0.1 --skip-initial-build --source "$SOURCE_DIR" --destination "$DEST_DIR" --config "$JEKYLL_CONFIG" JEKYLL_ENV="$JEKYLL_ENV"
