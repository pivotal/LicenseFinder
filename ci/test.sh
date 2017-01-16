#!/bin/bash

set -e -x

pushd LicenseFinder
  source /root/.bash_profile

  rbenv global $RUBY_VERSION
  ruby --version

  chmod +x ci/install_*.sh
  # ./ci/install_rebar.sh
  ./ci/install_bower.sh
  # ./ci/install_gradle.sh
  # ./ci/install_godep.sh
  export PATH=$PATH:$HOME/gradle/bin:$HOME/rebar:$HOME/go/bin GOPATH=$HOME/go
  export RUBYOPT='-E utf-8'
  
  gem update --system
  gem install bundler
  bundle install
  # rbenv global $RUBY_VERSION
  ruby --version
  bundler --version

  # bundle exec rake install
  # bundle exec rake spec
  # bundle exec rake features

  bundle exec rspec ./spec/lib/license_finder/package_managers/npm_spec.rb:149 # LicenseFinder::NPM.current_packages npm recursive dependency edge case - GH#211 .current_packages correctly navigates the dependencies tree and pulls out valid information

popd
