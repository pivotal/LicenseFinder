#!/bin/bash -ex

pushd ~

git clone --depth 1 git://github.com/rebar/rebar.git
cd rebar
./bootstrap

erl -version
PATH=$HOME/rebar:$PATH rebar --version

popd
