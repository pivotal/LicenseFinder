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
  apt-get -y install software-properties-common
  add-apt-repository -y ppa:webupd8team/java
  apt-get update
  echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | sudo debconf-set-selections
  apt -y install oracle-java8-set-default
fi


bundle exec rake install
bundle exec rake spec
bundle exec rake features



