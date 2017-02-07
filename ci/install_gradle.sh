#!/bin/bash
set -e
set -x

pushd /tmp

curl -L -o gradle.zip http://services.gradle.org/distributions/gradle-2.4-bin.zip
unzip -q gradle.zip
rm gradle.zip
mv gradle* ~/gradle

popd
