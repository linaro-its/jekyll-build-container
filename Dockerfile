# For building the Linaro Connect website

# Set the base image to Ubuntu (version 18.04)
# Uses the new "ubuntu-minimal" image
# Should be Alpine like all the cool kids, but
FROM ubuntu:18.04

# File Authors / Maintainers
# Initial Maintainer
LABEL maintainer="it-services@linaro.org"

################################################################################
# Basic APT commands
# Tell apt not to use interactive prompts
RUN export DEBIAN_FRONTEND=noninteractive && \
# Clean package cache and upgrade all installed packages
	apt-get clean -y && \
	apt-get update && \
	apt-get install apt-utils -y && \
	apt-get upgrade -y && \
# Clean up package cache in this layer
	apt-get --purge autoremove -y && \
	apt-get clean -y && \
# Restore interactive prompts
	unset DEBIAN_FRONTEND
################################################################################

################################################################################
# Configure locale for jekyll build
RUN export DEBIAN_FRONTEND=noninteractive && \
	apt-get install -y \
	language-pack-en \
	&& \
	locale-gen en_US.UTF-8 \
	&& \
# Set locale
	dpkg-reconfigure locales && \
# Remove stale dependencies
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
	build-essential \
# Ruby 2.5 development environment
	ruby2.5-dev \
# rmagick requires MagickWand libraries
	libmagickwand-dev \
# Required when building nokogiri
	autoconf \
# Required by coffeescript
	nodejs \
# Required for Python package installation
	python3-pip \
	python3-setuptools \
	&& \
	apt-get --purge autoremove -y && \
	apt-get clean -y
################################################################################

################################################################################
# Install Python packages used by the link checker
RUN pip3 install wheel
RUN pip3 install \
	bs4 \
	aiohttp
################################################################################

################################################################################
# Install Bundler
RUN gem install --conservative \
	bundler \
	jekyll

# Add update && upgrade to this layer in case we're rebuilding
RUN export DEBIAN_FRONTEND=noninteractive && \
	apt-get update && \
	apt-get upgrade -y && \
	apt-get --purge autoremove -y && \
	apt-get clean -y
################################################################################

################################################################################
# Dockerfile development only
ENV CONFIG_UPDATED 2018-08-10.1202
# COPY Gemfile /srv/Gemfile
################################################################################

COPY build-site.sh /usr/local/bin/
RUN chmod a+x /usr/local/bin/build-site.sh
COPY serve-site.sh /usr/local/bin/
RUN chmod a+x /usr/local/bin/serve-site.sh
COPY check-links-3.py /usr/local/bin/
RUN chmod a+x /usr/local/bin/check-links-3.py

WORKDIR /srv

EXPOSE 4000

CMD /bin/bash
