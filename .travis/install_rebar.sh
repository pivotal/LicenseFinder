#!/bin/bash
set -e
set -x

pushd /tmp

wget https://github.com/rebar/rebar/wiki/rebar
mkdir -p ~/rebar
mv rebar ~/rebar/
chmod u+x ~/rebar/rebar

erl -version
PATH=$HOME/rebar:$PATH rebar --version

popd
