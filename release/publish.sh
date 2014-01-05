#!/usr/bin/env bash -l

export LF_GEM_VERSION=`ruby release/gem_version.rb`

read -p "This will build and release license_finder $LF_GEM_VERSION -- are you sure you wish to continue? [Y/n] " -n 1 -r
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
  printf "\nAborted!"
  exit
fi

function perform {
  printf "\n> $1\n"
  $1
}

printf "\nBuilding jruby..."
perform "rvm use jruby"
perform "rake build"

printf "\nBuilding ruby..."
perform "rvm use ruby"
perform "rake build"

printf "\nPublishing to rubygems..."
perform "rake release"
perform "gem push pkg/license_finder-$LF_GEM_VERSION-java.gem"

printf "\nRelease finished."
