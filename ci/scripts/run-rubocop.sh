#!/bin/bash -e

cd LicenseFinder
gem install rubocop --version 0.51


echo "Running Rubocop ..."
/usr/local/bundle/bin/rubocop
