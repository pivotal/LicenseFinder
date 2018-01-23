#!/bin/bash

set -e

apk update && apk add git
source /opt/resource/common.sh
start_docker 3 3

pushd LicenseFinder
  if [ ! -z "$(git diff master Dockerfile)" ]; then
    docker build . -t licensefinder/license_finder
  fi

  docker run -v $PWD:/lf -it licensefinder/license_finder /bin/bash \
    -exlc "cd /lf && ci/scripts/run-tests.sh $RUBY_VERSION_UNDER_TEST"
popd
