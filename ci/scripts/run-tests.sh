#!/bin/bash -elx

set -o pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( dirname "$( dirname $DIR )" )"

pushd "$PROJECT_ROOT"
  DISABLE_BINARY=""
  if [[ $RUBY_VERSION_UNDER_TEST == "2.6.10" ]]; then
    DISABLE_BINARY="--disable-binary"
  fi

  # This is needed for 2.7 but also works for 2.6. For 2.6, you can also downgrade the openssl version to 1.1.1l-1ubuntu1.4 in the dockerfile with allowing downgrades for apt install -y libssl-dev=1.1.1l-1ubuntu1.4
  if [[ $RUBY_VERSION_UNDER_TEST == "2.6.10" || $RUBY_VERSION_UNDER_TEST == "2.7.8" ]]; then
    OPEN_SSL_FLAG="--with-openssl-dir=/usr/share/rvm/usr/"
    rvm pkg install openssl
  fi

  rvm install --default $RUBY_VERSION_UNDER_TEST $DISABLE_BINARY $OPEN_SSL_FLAG
  ruby --version

  export GOPATH=$HOME/go
  if [[ $RUBY_VERSION_UNDER_TEST == "2.6.10" || $RUBY_VERSION_UNDER_TEST == "2.7.8" ]]; then
    export RUBYOPT='-E utf-8 -W0'
    gem install "rubygems-update:<3.5.0" --no-document
    gem update --system --conservative
  else
    export RUBYOPT='-E utf-8'
    gem update --system
  fi

  gem install bundler
  bundle install
  bundle pristine

  rake install
  rake spec

  rake features
popd
