# Core tools for building Linaro's static web sites.

# Set the base image to Ubuntu (version 20.04).
# Uses the new "ubuntu-minimal" image.
FROM ubuntu:20.04

LABEL maintainer="it-services@linaro.org"

################################################################################
# Install locale packages from Ubuntu repositories and set locale.
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
# Install unversioned dependency packages from Ubuntu repositories.
# See also: https://jekyllrb.com/docs/installation/.

ENV UNVERSIONED_DEPENDENCY_PACKAGES \
 # Needed by the build-site script to determine if this is the latest container.
 curl \
 jq \
 # Needed by the build-site script to copy stuff and retrieve repos.
 rsync \
 git \
 # Jekyll prerequisites, except Ruby. https://jekyllrb.com/docs/installation/
 # The default Java Runtime Env - dependency of Google's Closure Compiler
 default-jre \
 build-essential \
 # Required for callback plugin.
 zlib1g-dev \
 # rmagick requires MagickWand libraries.
 libmagickwand-dev \
 # Required when building webp images.
 imagemagick \
 webp \
 # Required when building nokogiri.
 autoconf \
 # Required by autofixer-rails.
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
# Install versioned dependency packages from Ubuntu repositories.
# This is the last layer which will update Ubuntu packages.

ENV VERSIONED_PACKAGES \
 ruby-dev
LABEL org.linaro.versioned=${VERSIONED_PACKAGES}

RUN export DEBIAN_FRONTEND=noninteractive && \
 apt-get update && \
 apt-get upgrade -y && \
 apt-get install -y --no-install-recommends \
 ${VERSIONED_PACKAGES} \
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
# Install the gems required across all static web sites built by Linaro.
# Note that jumbo-jekyll-theme specifies the version of Jekyll it uses which is
# why we don't explicitly install Jekyll.
#
# We use gem install rather than a mega-Gemfile because Gemfiles only allow you
# to have one version of each gem specified.

ENV RUBY_GEMS \
 # Required for "bundle exec"
 bundler:1.17.2 \
 # Newer version to ensure later gem installation
 rake:12.3.2 \
 #
 # Gems required across the web sites. Please comment to ensure everyone knows
 # which gem is used by which web site. If you are removing a web site as a user
 # of a gem and it is the last site using that gem, please remove the gem!
 #
 # Used by 96boards.ai, 96boards.org, connect.linaro.org, devicetree.org, linaro.cloud, linaro.org,
 # lkft.linaro.org, mlplatform.org, op-tee.org, trustedfirmware.org
 jekyll-data:1.0.0 \
 # Used by connect.linaro.org, linaro.cloud
 jekyll-include-cache:0.2.0 \
 # Used by devicetree.org
 jekyll-minimagick:0.0.4 \
 # Jekyll static site builder
 jekyll:3.8.7 \
 jekyll:4.0.1 \
 # Used by 96boards.org
 jekyll-relative-links:0.6.0 \
 jekyll-relative-links:0.6.1 \
 # Used by connect.linaro.org, linaro.cloud
 jekyll-responsive-image:1.5.2 \
 # Used by 96boards.org
 jekyll-toc:0.15.0 \
 jekyll-readme-index:0.3.0 \
 # Used by devicetree.org, op-tee.org
 mini_magick:4.9.3 \
 # Used by connect.linaro.org, linaro.cloud, linaro.org
 nokogiri:1.10.4 \
 # Used by (staging.)lkft.linaro.org
 seriously_simple_static_starter:0.7.0 \
 # linaro-jekyll-theme latest versions
 linaro-jekyll-theme:4.3.3 \
 linaro-jekyll-theme:4.3.0 \
 linaro-jekyll-theme:4.2.0 \
 linaro-jekyll-theme:4.1.6 \
 linaro-jekyll-theme:4.1.5 \
 linaro-jekyll-theme:4.1.4 \
 linaro-jekyll-theme:4.1.3 \
 linaro-jekyll-theme:4.1.2 \
 closure-compiler \
 # Staged for removal (ensures builds pass)
 jumbo-jekyll-theme:6.0.2.1 \
 jumbo-jekyll-theme:5.6.9.2 

LABEL org.linaro.gems=${RUBY_GEMS}

RUN gem install --no-document \
 ${RUBY_GEMS}

################################################################################
# Install Linaro ITS build script.

COPY build-site.sh /usr/local/bin/
RUN chmod a+rx /usr/local/bin/build-site.sh

################################################################################
# Record the Bamboo build job (if specified as an argument)
ARG bamboo_build
ENV BAMBOO_BUILD=${bamboo_build}

WORKDIR /srv
EXPOSE 4000

ENTRYPOINT ["/usr/local/bin/build-site.sh"]
CMD []
