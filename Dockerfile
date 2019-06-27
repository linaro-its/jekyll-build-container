# Core tools for building Linaro's static web sites.

# Set the base image to Ubuntu (version 18.04) Uses the new "ubuntu-minimal"
# image Should be Alpine like all the cool kids, but
ARG UBUNTU_VERSION=18.04
FROM ubuntu:${UBUNTU_VERSION}

LABEL maintainer="it-services@linaro.org"

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
# Install unversioned dependency packages from Ubuntu repositories
# See also: https://jekyllrb.com/docs/installation/
ENV UNVERSIONED_DEPENDENCY_PACKAGES \
# Jekyll prerequisites, https://jekyllrb.com/docs/installation/
 build-essential \
# Required for callback plugin
 zlib1g-dev \
# rmagick requires MagickWand libraries
  libmagickwand-dev \
# Required when building webp images
 imagemagick \
 webp \
# Required when building nokogiri
 autoconf \
# Required by autofixer-rails
 nodejs

RUN export DEBIAN_FRONTEND=noninteractive && \
 apt-get update && \
 apt-get upgrade -y && \
 apt-get install -y --no-install-recommends \
 ${UNVERSIONED_DEPENDENCY_PACKAGES} \
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

# Changing ARG values below will cause subsequent layers to be rebuilt

################################################################################
# Install versioned dependency packages from Ubuntu repositories
# This is the last layer which will update Ubuntu packages
# For hacking, override the Ruby package name with e.g:
# `--build-arg RUBY_PACKAGE_VERSION=2.5`
ARG RUBY_PACKAGE_VERSION=2.5-dev
ENV RUBY_PACKAGE_VERSION ${RUBY_PACKAGE_VERSION}
LABEL Ruby=ruby${RUBY_PACKAGE_VERSION}
RUN export DEBIAN_FRONTEND=noninteractive && \
 apt-get update && \
 apt-get upgrade -y && \
 apt-get install -y --no-install-recommends \
# Jekyll prerequisites, https://jekyllrb.com/docs/installation/
 ruby${RUBY_PACKAGE_VERSION} \
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
# Install versioned dependency packages from Ubuntu repositories
# This is the last layer which will update Ubuntu packages
# For hacking, override the Ruby package name with e.g:
# `--build-arg RUBY_PACKAGE_VERSION=2.5`
RUN export DEBIAN_FRONTEND=noninteractive && \
 apt-get update && \
 apt-get upgrade -y && \
 apt-get install -y --no-install-recommends \
# Jekyll prerequisites, https://jekyllrb.com/docs/installation/
 ruby-full \
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
# Install Ruby Gem dependencies.
# Ruby Gem versions can be overridden per-site by website repo, e.g by:
# https://rubygems.org/gems/jumbo-jekyll-theme/versions/

# Install Bundler
ARG BUNDLER_GEM_VERSION=1.17.2
ENV BUNDLER_GEM_VERSION ${BUNDLER_GEM_VERSION}
LABEL Bundler=${BUNDLER_GEM_VERSION}
RUN gem install --no-user-install bundler -v ${BUNDLER_GEM_VERSION}

# Install Jekyll
# NB: Sass deprecation warning is currently expected. See
# https://talk.jekyllrb.com/t/do-i-need-to-update-sass/2509
ARG JEKYLL_GEM_VERSION=3.8.5
ENV JEKYLL_GEM_VERSION ${JEKYLL_GEM_VERSION}
LABEL Jekyll=${JEKYLL_GEM_VERSION}
RUN gem install --no-user-install jekyll -v ${JEKYLL_GEM_VERSION}
################################################################################

WORKDIR /srv
EXPOSE 4000
# CMD /bin/bash
