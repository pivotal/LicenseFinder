#!/bin/bash -elx

set -o pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( dirname "$( dirname $DIR )" )"

pushd "$PROJECT_ROOT"

  rvm install --default $RUBY_VERSION_UNDER_TEST
  ruby --version

  export GOPATH=$HOME/go
  export RUBYOPT='-E utf-8'

  gem update --system
  gem install bundler

  # Install bundler v1 for older projects
  # https://bundler.io/guides/bundler_2_upgrade.html#version-autoswitch
  gem install bundler -v 1.17.3

  bundle install

  bundle exec rake install
  bundle exec rake spec

  bundle exec rake features
popd
