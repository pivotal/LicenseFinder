#!/bin/bash

set -e -x

pushd LicenseFinder
  gem install bundler
  bundle install
  ls -al
  rspec spec/lib/license_finder/license_spec.rb
popd
