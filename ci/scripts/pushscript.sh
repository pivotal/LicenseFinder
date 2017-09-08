#!/bin/bash

echo -e "---\n:rubygems_api_key: $GEM_API_KEY" > ~/.gem/credentials
chmod 0600 ~/.gem/credentials

cd LicenseFinder
buildVersion=$(cat lib/license_finder/version.rb | grep -o '[0-9].[0-9].[0-9]')
specName=$(cat license_finder.gemspec | grep "s[.]name" | awk '{ gsub(/"/, "", $3); print $3}')
buildName="pkg/$specName-$buildVersion.gem"

rake build
gem push ${buildName}
