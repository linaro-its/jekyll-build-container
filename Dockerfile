# Core tools for building Linaro's static web sites.

# Set the base image to Ubuntu (version 18.04)
# Uses the new "ubuntu-minimal" image
# Should be Alpine like all the cool kids, but
ARG UBUNTU_VERSION=18.04
FROM ubuntu:${UBUNTU_VERSION}

# Can be overridden per-site by website repo, e.g by dependencies of:
# https://rubygems.org/gems/jumbo-jekyll-theme/versions/
ARG JEKYLL_GEM_VERSION
ENV JEKYLL_GEM_VERSION ${JEKYLL_GEM_VERSION:-3.8.5}

# Can be overridden per-site by website repo:
ARG BUNDLER_GEM_VERSION
ENV BUNDLER_GEM_VERSION ${BUNDLER_GEM_VERSION:-2.0.2}

ARG RUBY_PACKAGE_VERSION
ENV RUBY_PACKAGE_VERSION ${RUBY_PACKAGE_VERSION:-2.5-dev}

# Jekyll prerequisites, https://jekyllrb.com/docs/installation/
ENV UNVERSIONED_PACKAGES \
# Required for callback plugin
 gcc \
 libc6-dev \
 make

# File Authors / Maintainers
# Initial Maintainer
LABEL maintainer="it-services@linaro.org"
LABEL Bundler=${BUNDLER_GEM_VERSION}
LABEL Jekyll=${JEKYLL_GEM_VERSION}

################################################################################
# Install locale packages from Ubuntu repositories and set locale
RUN export DEBIAN_FRONTEND=noninteractive && \
 apt-get clean -y && \
 apt-get update && \
 apt-get install apt-utils -y && \
 apt-get upgrade -y && \
 apt-get install -y language-pack-en && \
 locale-gen en_US.UTF-8 && \
 dpkg-reconfigure locales && \
 apt-get --purge autoremove -y && \
 apt-get clean -y \
 && \
 rm -rf \
 /tmp/* \
 /var/cache/* \
 /var/lib/apt/lists/* \
 /var/log/*

# Set the defaults
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
################################################################################

################################################################################
# Install packages from Ubuntu repositories
# Add update && upgrade to this layer in case we're rebuilding from here down
RUN export DEBIAN_FRONTEND=noninteractive && \
 apt-get update && \
 apt-get upgrade -y && \
 apt-get install -y --no-install-recommends \
# Jekyll prerequisites, https://jekyllrb.com/docs/installation/
 ruby${RUBY_PACKAGE_VERSION} \
 ${UNVERSIONED_PACKAGES} \
# Jekyll site extra prerequisites
#  ruby-full \
#  build-essential \
#  zlib1g-dev \
# # rmagick requires MagickWand libraries
#  libmagickwand-dev \
# # Required when building webp images
#  imagemagick \
#  webp \
# # Required when building nokogiri
#  autoconf \
# # Required by coffeescript
#  nodejs \
 && \
 apt-get --purge autoremove -y && \
 apt-get clean -y \
 && \
 rm -rf \
 /tmp/* \
 /var/cache/* \
 /var/lib/apt/lists/* \
 /var/log/*
################################################################################

################################################################################
# Install Bundler and Jekyll
RUN gem install --conservative \
 bundler -v ${BUNDLER_GEM_VERSION}
RUN gem install --conservative \
 jekyll -v ${JEKYLL_GEM_VERSION} \
################################################################################

WORKDIR /srv
EXPOSE 4000
# CMD /bin/bash
