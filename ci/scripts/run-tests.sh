#!/bin/bash -elx

set -o pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( dirname "$( dirname $DIR )" )"

pushd "$PROJECT_ROOT"
  DISABLE_BINARY=""
  if [[ $RUBY_VERSION_UNDER_TEST == "2.6.10" ]]; then
    DISABLE_BINARY="--disable-binary"
  fi

  rvm install --default $RUBY_VERSION_UNDER_TEST $DISABLE_BINARY
  ruby --version

  export GOPATH=$HOME/go
  export RUBYOPT='-E utf-8'

  gem update --system
  gem install bundler
  bundle install
  bundle pristine

  rake install
  rake spec

  rake features
popd
