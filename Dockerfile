# Core tools for building Linaro's static web sites.

# Set the base image to Ubuntu (version 18.04).
# Uses the new "ubuntu-minimal" image.
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

# Install unversioned dependency packages from Ubuntu repositories
# See also: https://jekyllrb.com/docs/installation/
ENV UNVERSIONED_DEPENDENCY_PACKAGES \
# Needed by the build-site script to determine if this is the latest container
 curl \
 jq \
# Jekyll prerequisites, except Ruby. https://jekyllrb.com/docs/installation/
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

# Bundler specification
ARG BUNDLER_GEM_VERSION=1.17.2
ENV BUNDLER_GEM_VERSION ${BUNDLER_GEM_VERSION}
LABEL Bundler=${BUNDLER_GEM_VERSION}

# Rake specification (otherwise some of the required gems below won't install)
ARG RAKE_GEM_VERSION=12.3.2
ENV RAKE_GEM_VERSION ${RAKE_GEM_VERSION}
LABEL Rake=${RAKE_GEM_VERSION}

# and install into a single layer
RUN gem install --no-document \
 bundler:${BUNDLER_GEM_VERSION} \
 rake:${RAKE_GEM_VERSION}

################################################################################

# Install the gems required across all static web sites built by Linaro.
# Note that jumbo-jekyll-theme specifies the version of Jekyll it uses which is
# why we don't explicitly install Jekyll.
#
# We use gem install rather than a mega-Gemfile because Gemfiles only allow you
# to have one version of each gem specified.
RUN gem install --no-document \
 jekyll-data:1.0.0 \
 jekyll-include-cache:0.2.0 \
 jekyll-minimagick:0.0.4 \
 jekyll-relative-links:0.6.0 \
 jekyll-responsive-image:1.5.2 \
 jekyll-titles-from-headings:0.5.1 \
 jumbo-jekyll-theme:3.9.4 \
 jumbo-jekyll-theme:4.4.4 \
 jumbo-jekyll-theme:4.4.9 \
 jumbo-jekyll-theme:4.5.0 \
 jumbo-jekyll-theme:4.7.6 \
 jumbo-jekyll-theme:4.7.7 \
 jumbo-jekyll-theme:5.3.4 \
 mini_magick:4.9.3 \
 nokogiri:1.10.3 \
 seriously_simple_static_starter:0.5.0

################################################################################

# Install Linaro ITS build scripts
COPY build-site.sh /usr/local/bin/
COPY bamboo-build.txt /usr/local/etc/
RUN chmod a+rx /usr/local/bin/build-site.sh
RUN chmod a+r /usr/local/etc/bamboo-build.txt

WORKDIR /srv
EXPOSE 4000
