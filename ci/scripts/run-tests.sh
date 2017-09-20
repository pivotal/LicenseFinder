#!/bin/bash -elx
RUBY_VERSION_UNDER_TEST=$1
rvm install --default $RUBY_VERSION_UNDER_TEST
ruby --version

export GOPATH=$HOME/go
export RUBYOPT='-E utf-8'

gem update --system
gem install bundler
bundle install

# jruby-9 specific: requires  >= rack 2.x
if [ "$RUBY_VERSION_UNDER_TEST" == "jruby-9.0.4.0" ]
then
  bundle update rack
fi
#

bundle exec rake install
bundle exec rake spec
bundle exec rake features
