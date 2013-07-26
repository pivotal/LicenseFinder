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

printf "\nBuilding jruby... (1.7.4)"
perform "rvm use jruby-1.7.4"
perform "rake build"

printf "\nBuilding ruby... (2.0.0)"
perform "rvm use ruby-2.0.0"
perform "rake build"

printf "\nPublishing to rubygems..."
perform "rake release"
perform "gem push pkg/license_finder-$LF_GEM_VERSION-java.gem"

printf "\nRelease finished."
