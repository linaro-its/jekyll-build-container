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

# Install packages
RUN export DEBIAN_FRONTEND=noninteractive && \
	apt-get update && \
	apt-get upgrade -y && \
	apt-get install -y --no-install-recommends \
# Jekyll prerequisites, https://jekyllrb.com/docs/installation/
	ruby-full \
	build-essential \
	zlib1g-dev \
# rmagick requires MagickWand libraries
 	libmagickwand-dev \
# Required when building webp images
	imagemagick \
	webp \
# Required when building nokogiri
	autoconf \
# Required by autofixer-rails
	nodejs \
	&& \
# Install Bundler
	gem install --conservative bundler:1.17.2 \
	&& \
# Some gems are getting preinstalled by ruby-full so we need to get them
# upgraded before we go any further.
	gem upgrade && \
	apt-get autoremove -y && \
	apt-get clean -y

################################################################################

# Install the gems required across all static web sites built by Linaro.
# Note that jumbo-jekyll-theme specifies the version of Jekyll it uses which is
# why we don't explicitly install Jekyll.
#
# We use gem install rather than a mega-Gemfile because Gemfiles only allow you
# to have one version of each gem specified.
RUN gem install --no-ri --no-rdoc \
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
	jumbo-jekyll-theme:5.3.4 \
	jumbo-jeykll-theme:4.7.7 \
	mini_magick:4.9.3 \
	nokogiri:1.10.3 \
	seriously_simple_static_starter:0.5.0

################################################################################

COPY build-site.sh /usr/local/bin/
COPY bamboo-build.txt /usr/local/etc/
RUN chmod a+rx /usr/local/bin/build-site.sh
RUN chmod a+r /usr/local/etc/bamboo-build.txt

WORKDIR /srv
EXPOSE 4000
