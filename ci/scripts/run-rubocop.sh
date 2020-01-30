#!/bin/bash -e

cd LicenseFinder

gem update --system
bundle install --without runtime default

rubocop_version=`cat Gemfile.lock | grep '    rubocop' | awk -F'[\(*\)]' '{print $2;exit}'`
rubocop_performance_version=`cat Gemfile.lock | grep '    rubocop-performance' | awk -F'[\(*\)]' '{print $2;exit}'`

gem install rubocop --version $rubocop_version
gem install rubocop-performance --version $rubocop_performance_version

echo "Running Rubocop ..."
/usr/local/bundle/bin/rubocop --require rubocop-performance
