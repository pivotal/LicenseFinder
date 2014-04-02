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

printf "\nBuilding jruby gem"
perform "rvm use jruby"
perform "gem build *.gemspec"

printf "\nBuilding ruby gem"
perform "rvm use ruby"
perform "gem build *.gemspec"

for file in *.gem
do
    perform "gem push $file"
done

perform "rm *.gem"

printf "\nRelease finished."
