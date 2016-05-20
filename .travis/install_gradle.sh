#!/bin/bash -ex

pushd /tmp

wget http://services.gradle.org/distributions/gradle-2.4-all.zip
unzip -q gradle*
rm gradle*.zip
mv gradle* ~/gradle

popd
