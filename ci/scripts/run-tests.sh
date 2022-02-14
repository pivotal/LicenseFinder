#!/bin/bash -elx

set -o pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( dirname "$( dirname $DIR )" )"

pushd "$PROJECT_ROOT"

  gem update --system
  # Since we update the system gem, we need to ensure that RVM
  # re-installs requested ruby version to ensure it is
  # installed correctly again. If the ruby version is does not exist,
  # re-install will install it.
  rvm reinstall --default $RUBY_VERSION_UNDER_TEST
  ruby --version

  export GOPATH=$HOME/go
  export RUBYOPT='-E utf-8'

  gem install bundler
  bundle install

  bundle exec rake install
  bundle exec rake spec

  bundle exec rake features
popd
