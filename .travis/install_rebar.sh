#!/bin/bash
set -e
set -x

pushd /tmp

git clone --depth 1 git://github.com/rebar/rebar.git
cd rebar
./bootstrap

mkdir -p ~/rebar
mv rebar ~/rebar/

erl -version
PATH=$HOME/rebar:$PATH rebar --version

popd
