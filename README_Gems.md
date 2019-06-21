# Jekyll and Bundler Gems

[Jekyll](https://jekyllrb.com/) and [Bundler](https://bundler.io/) are preinstalled as Ruby Gems as the versions packaged for Ubuntu are quite old:

```bash
root@c7cfe6719c83:/srv# apt-cache show jekyll | grep -E 'Depend|Version'
Version: 3.1.6+dfsg-3
Depends: ruby | ruby-interpreter, ruby-classifier-reborn, ruby-colorator, ruby-jekyll-coffeescript (>= 1.0.1-2~), ruby-jekyll-feed, ruby-jekyll-gist, ruby-jekyll-paginate, ruby-jekyll-sass-converter, ruby-jekyll-watch, ruby-kramdown, ruby-launchy-shim, ruby-liquid, ruby-mercenary, ruby-mime-types, ruby-pygments.rb, ruby-rdiscount, ruby-redcarpet, ruby-rouge, ruby-safe-yaml, ruby-toml (>= 0.1.2-2~), xdg-utils
Ruby-Versions: all
root@c7cfe6719c83:/srv# apt-cache show bundler | grep -E 'Depend|Version'
Version: 1.16.1-1
Depends: ruby-bundler (= 1.16.1-1)
root@c7cfe6719c83:/srv#
```

Gem versions can be overridden by the website build dependencies: the only reason they're in the `docker image` is to accelerate building with a common version. Our dependency handling may change in future.
