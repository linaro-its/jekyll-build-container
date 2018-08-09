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
# Install the bundle
bundle Install
#
# Build the site
bundle exec jekyll build --config "$JEKYLL_CONFIG" JEKYLL_ENV="$JEKYLL_ENV"
