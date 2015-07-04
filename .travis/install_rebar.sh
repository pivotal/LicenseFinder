#!/bin/bash
set -e
set -x

pushd /tmp

wget https://raw.github.com/wiki/rebar/rebar/rebar
mkdir -p ~/rebar
mv rebar ~/rebar/
chmod u+x ~/rebar/rebar

popd
