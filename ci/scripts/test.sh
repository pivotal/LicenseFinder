#!/bin/bash --login

set -e -x

pushd LicenseFinder
  rvm install $RUBY_VERSION
  rvm use $RUBY_VERSION
  ruby --version

  export GOPATH=$HOME/go
  export RUBYOPT='-E utf-8'

  gem update --system
  gem install bundler
  bundle install

  # jruby-9 specific: requires  >= rack 2.x
  if [ "$RUBY_VERSION" == "jruby-9.0.4.0" ]
  then
    bundle update rack
  fi
  #

  bundle exec rake install
  bundle exec rake spec
  bundle exec rake features
popd
