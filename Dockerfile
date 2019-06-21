# Core tools for building Linaro's static web sites.

# Set the base image to Ubuntu (version 18.04)
# Uses the new "ubuntu-minimal" image
# Should be Alpine like all the cool kids, but
FROM ubuntu:18.04

# File Authors / Maintainers
# Initial Maintainer
LABEL maintainer="it-services@linaro.org"

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

################################################################################
# Install latest software
# Change the date time stamp if you want to rebuild the image from this point down
# Useful for Dockerfile development
ENV SOFTWARE_UPDATED 2018-08-10.1202

# Install packages
# Add update && upgrade to this layer in case we're rebuilding from here down
RUN export DEBIAN_FRONTEND=noninteractive && \
	apt-get update && \
	apt-get upgrade -y && \
	apt-get install -y --no-install-recommends \
# Jekyll prerequisites, https://jekyllrb.com/docs/installation/
	ruby2.5-dev \
	gcc \
	make \
	libc6-dev \
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
	rm -fr \
	/var/cache \
	/var/lib/apt/lists \
	/var/log
# Install Bundler
# NB: Sass deprecation warning is currently expected. See
#     https://talk.jekyllrb.com/t/do-i-need-to-update-sass/2509
RUN gem install --conservative \
	bundler:1.17.2 \
	jekyll
# ################################################################################

WORKDIR /srv
EXPOSE 4000
# CMD /bin/bash
