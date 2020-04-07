#!/bin/bash

echo -e "---\n:rubygems_api_key: $GEM_API_KEY" > ~/.gem/credentials
chmod 0600 ~/.gem/credentials

build_version="$(cat semver-version/version)"
cd lf-git
built_gem="pkg/license_finder-$build_version.gem"

git config --global user.email $GIT_EMAIL
git config --global user.name $GIT_USERNAME

git config --global push.default simple

git checkout master

mkdir ~/.ssh
ssh-keyscan github.com >> ~/.ssh/known_hosts
eval "$(ssh-agent -s)"
echo "$GIT_PRIVATE_KEY" > ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa
ssh-add -k ~/.ssh/id_rsa

if [ -z "$(gem fetch license_finder -v $build_version 2>&1 | grep ERROR)" ]; then
  echo "LicenseFinder-$build_version already exists on Rubygems"
else
  rake release
fi

export EXIT_STATUS=$?
kill $(ps aux | grep ssh-agent | head -n 1 | awk '{print $2}')
exit $EXIT_STATUS
