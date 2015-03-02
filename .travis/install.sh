#!/bin/bash
set -e
set -x

pushd /tmp

echo $PATH

wget http://services.gradle.org/distributions/gradle-1.11-all.zip
unzip -q gradle*
rm gradle*.zip
mv gradle* ~/gradle

wget https://raw.github.com/wiki/rebar/rebar/rebar
mkdir ~/rebar
mv rebar ~/rebar/
chmod u+x ~/rebar/rebar

npm install -g bower

popd
