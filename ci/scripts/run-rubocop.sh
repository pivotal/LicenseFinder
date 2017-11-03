#!/bin/bash -e

cd LicenseFinder
gem install rubocop


echo "Running Rubocop ..."
/usr/local/bundle/bin/rubocop
