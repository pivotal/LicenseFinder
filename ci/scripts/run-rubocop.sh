#!/bin/bash -e

cd LicenseFinder
gem install rubocop --version 0.59.1


echo "Running Rubocop ..."
/usr/local/bundle/bin/rubocop
