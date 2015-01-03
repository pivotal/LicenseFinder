#!/usr/bin/env bash -l

export LF_GEM_VERSION=`ruby release/gem_version.rb`

read -p "This will build and release license_finder $LF_GEM_VERSION -- are you sure you wish to continue? [Y/n] " -n 1 -r
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
  printf "\nAborted!"
  exit
fi

set -x

perform "gem build *.gemspec"
perform "gem push *gem"
perform "rm *.gem"

printf "\nRelease finished."
