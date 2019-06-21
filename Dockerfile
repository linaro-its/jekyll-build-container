# Core tools for building Linaro's static web sites.

# Set the base image to Ubuntu (version 18.04)
# Uses the new "ubuntu-minimal" image
# Should be Alpine like all the cool kids, but
ARG UBUNTU_VERSION=18.04
FROM ubuntu:${UBUNTU_VERSION}

# Can be overridden per-site by jumbo-jekyll-theme:
# https://rubygems.org/gems/jumbo-jekyll-theme/versions/
ARG JEKYLL_GEM_VERSION
ENV JEKYLL_GEM_VERSION ${JEKYLL_GEM_VERSION:-3.8.5}

# Can be overridden per-site by jumbo-jekyll-theme:
ARG BUNDLER_GEM_VERSION
ENV BUNDLER_GEM_VERSION ${BUNDLER_GEM_VERSION:-2.02}

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
LABEL maintainer="ciaran.moran@linaro.org"

################################################################################
RUN export DEBIAN_FRONTEND=noninteractive && \
	apt-get clean -y && \
	apt-get update && \
	apt-get install apt-utils -y && \
	apt-get upgrade -y && \
	apt-get install -y language-pack-en && \
	locale-gen en_US.UTF-8 && \
	dpkg-reconfigure locales && \
	apt-get --purge autoremove -y && \
	apt-get clean -y

# Set the defaults
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
################################################################################

# Install packages
# Add update && upgrade to this layer in case we're rebuilding from here down
RUN export DEBIAN_FRONTEND=noninteractive && \
	apt-get update && \
	apt-get upgrade -y && \
	apt-get install -y --no-install-recommends \
# Jekyll prerequisites, https://jekyllrb.com/docs/installation/
	ruby${RUBY_PACKAGE_VERSION} \
	${UNVERSIONED_PACKAGES} \
# Jekyll site extra prerequisites
# 	ruby-full \
# 	build-essential \
# 	zlib1g-dev \
# # rmagick requires MagickWand libraries
# 	libmagickwand-dev \
# # Required when building webp images
# 	imagemagick \
# 	webp \
# # Required when building nokogiri
# 	autoconf \
# # Required by coffeescript
# 	nodejs \
	&& \
	apt-get --purge autoremove -y && \
	apt-get clean -y \
	&& \
	rm -rf \
	/tmp/* \
	/var/cache/* \
	/var/lib/apt/lists/* \
	/var/log/*
# Install Bundler
# NB: Sass deprecation warning is currently expected. See
#     https://talk.jekyllrb.com/t/do-i-need-to-update-sass/2509
RUN gem install --conservative \
	bundler -v ${BUNDLER_GEM_VERSION}
RUN gem install --conservative \
	jekyll -v ${JEKYLL_GEM_VERSION} \
	&& \
	true
	# gem update --system
# ################################################################################

WORKDIR /srv
EXPOSE 4000
# CMD /bin/bash
