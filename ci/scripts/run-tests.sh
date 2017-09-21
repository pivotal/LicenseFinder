#!/bin/bash -el
RUBY_VERSION_UNDER_TEST=$1
if [ "$RUBY_VERSION_UNDER_TEST" == "jruby-9.0.4.0" ]; then
  echo "using 32-bit JRE"
  export JAVA_HOME="/usr/lib/jvm/java-1.7.0-openjdk-i386"
  export JAVA_OPTS="-client"
  cp /usr/lib/jvm/oracle_jdk8/jre/lib/security/cacerts /usr/lib/jvm/java-1.7.0-openjdk-i386/jre/lib/security/cacerts
  export JRUBY_OPTS="--dev"
fi
rvm install --default $RUBY_VERSION_UNDER_TEST
ruby --version

export GOPATH=$HOME/go
export RUBYOPT='-E utf-8'

gem update --system
gem install bundler
bundle install

# jruby-9 specific: requires  >= rack 2.x
if [ "$RUBY_VERSION_UNDER_TEST" == "jruby-9.0.4.0" ]; then
  bundle update rack
fi
#

bundle exec rake install
export JAVA_HOME="/usr/lib/jvm/oracle_jdk8"
export JAVA_OPTS=""
bundle exec rake spec
export JAVA_HOME="/usr/lib/jvm/java-1.7.0-openjdk-i386"
export JAVA_OPTS="-client"
bundle exec rake features
