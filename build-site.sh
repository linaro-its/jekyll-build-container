#!/bin/bash
#
# This script is run inside the Docker container to build the static web site using Jekyll.

function get_tag_for_latest(){
    LATEST_ALIAS=""
    # From https://stackoverflow.com/a/41830007/1233830
    REPOSITORY="linaroits/jekyllsitebuild"
    TARGET_TAG="latest"
    # check that we have Internet access - bail quickly if we don't
    HEAD=$(curl -s "https://auth.docker.io") || return $?
    # get authorization token
    TOKEN=$(curl -s "https://auth.docker.io/token?service=registry.docker.io&scope=repository:$REPOSITORY:pull" | jq -r .token) || return $?
    # find all tags
    ALL_TAGS=$(curl -s -H "Authorization: Bearer $TOKEN" https://index.docker.io/v2/$REPOSITORY/tags/list | jq -r .tags[]) || return $?
    # get image digest for target
    TARGET_DIGEST=$(curl -s -D - -H "Authorization: Bearer $TOKEN" -H "Accept: application/vnd.docker.distribution.manifest.v2+json" https://index.docker.io/v2/$REPOSITORY/manifests/$TARGET_TAG | grep Docker-Content-Digest | cut -d ' ' -f 2) || return $?
    # for each tags
    for tag in "${ALL_TAGS[@]}"; do
        # get image digest
        digest=$(curl -s -D - -H "Authorization: Bearer $TOKEN" -H "Accept: application/vnd.docker.distribution.manifest.v2+json" https://index.docker.io/v2/$REPOSITORY/manifests/$tag | grep Docker-Content-Digest | cut -d ' ' -f 2) || return $?
        # check digest
        if [ "$TARGET_DIGEST" = "$digest" ] && [ "$tag" != "$TARGET_TAG" ]; then
            LATEST_ALIAS="$tag"
        fi
    done
}

#
# If possible, show which container version this is
if [ ! -z "${BAMBOO_BUILD}" ]; then
    echo "Container built by bamboo.linaro.org: ${BAMBOO_BUILD}"
    get_tag_for_latest || LATEST_ALIAS=""
    if [ ! -z "$LATEST_ALIAS" ] && [ "$LATEST_ALIAS" != "${BAMBOO_BUILD}" ]; then
        echo "******************************************************************"
        echo "WARNING! This does not appear to be the latest Docker image:"
        echo "         $LATEST_ALIAS"
        echo "If the build fails, please 'docker pull linaroits/jekyllsitebuild'"
        echo "and try again."
        echo "******************************************************************"
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
    JEKYLL_ACTION="build"
fi
if [ "$JEKYLL_ACTION" == "serve" ]; then
    HOSTING_OPTIONS="-H0.0.0.0"
else
    HOSTING_OPTIONS=""
fi
#
# Change to the source directory because Jekyll expects it to be in the
# current directory.
cd "/srv/source" || exit
#
# If there is a Gemfile.lock, delete it because it may reference child-gems
# that the build container doesn't have installed.
if [ -f "Gemfile.lock" ]; then
    rm Gemfile.lock
fi
#
# Validate the source material before trying to build the site
echo "Validating source files"
bundle exec jekyll doctor \
 --config "_config.yml,_config-$JEKYLL_ENV.yml" \
 JEKYLL_ENV="$JEKYLL_ENV"
result=$?
if [ $result -ne 0 ]; then
    exit $result
fi
#
# ^^^ returns a non-zero code in the event of an error so we then
#     don't go any further.
#
# Build the site
echo "Building site"
bundle exec jekyll \
 "$JEKYLL_ACTION" \
 "$HOSTING_OPTIONS" \
 --strict_front_matter \
 --trace \
 --config "_config.yml,_config-$JEKYLL_ENV.yml" \
 "$@" \
 JEKYLL_ENV="$JEKYLL_ENV"
