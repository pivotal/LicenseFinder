#!/bin/bash

set -e -x

pushd LicenseFinder
  source /root/.bash_profile
  rbenv global $RUBY_VERSION
  chmod +x ci/install_*.sh
  ./ci/install_rebar.sh
  ./ci/install_bower.sh
  ./ci/install_gradle.sh
  ./ci/install_godep.sh
  export PATH=$PATH:$HOME/gradle/bin:$HOME/rebar:$HOME/go/bin GOPATH=$HOME/go

  gem install bundler
  bundle install

  bundle exec rake install
  bundle exec rake spec
  bundle exec rake features
popd
