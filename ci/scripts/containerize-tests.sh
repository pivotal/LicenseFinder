#!/bin/bash

set -e

apk update && apk add git
source /opt/resource/common.sh
start_docker 3 3

pushd LicenseFinder
  docker build . -t licensefinder/license_finder

  docker run -v $PWD:/lf -it licensefinder/license_finder /bin/bash \
    -exli /lf/ci/scripts/run-tests.sh "$RUBY_VERSION_UNDER_TEST"
popd
