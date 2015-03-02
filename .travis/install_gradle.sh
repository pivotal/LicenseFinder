#!/bin/bash
set -e
set -x

pushd /tmp

wget http://services.gradle.org/distributions/gradle-1.11-all.zip
unzip -q gradle*
rm gradle*.zip
mv gradle* ~/gradle

popd
