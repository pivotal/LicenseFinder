#!/bin/bash -ex

pushd /tmp

wget $(wget -qO- https://services.gradle.org/versions/current | jq -r .downloadUrl)
unzip -q gradle*
rm gradle*.zip
mv gradle* ~/gradle

popd
