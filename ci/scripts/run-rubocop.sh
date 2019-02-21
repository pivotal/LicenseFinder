#!/bin/bash -e

cd LicenseFinder

bundle install --without runtime default

version=`cat Gemfile.lock | grep '    rubocop' | awk -F'[\(*\)]' '{print $2}'`
gem install rubocop --version $version

echo "Running Rubocop ..."
/usr/local/bundle/bin/rubocop
