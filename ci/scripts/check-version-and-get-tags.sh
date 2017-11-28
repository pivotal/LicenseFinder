#!/bin/bash --login

set -e

version=$(ruby -r ./lf-git/lib/license_finder/version.rb -e "puts LicenseFinder::VERSION")
old=$(cat ./lf-release/version)
echo "New version: $version"
echo "Current version: $old"
if [ "$version" == "$old" ]; then
    echo "Error: Version in version.rb is identical to latest release on github"
    exit 1
fi
echo "v$version" > version/tag.txt
echo "$version" > version/version.txt
body=$(cat ./lf-git/CHANGELOG.md | sed -n "/# \[$version\]/,/# \[[\d\.]*/p" | sed '$d' | tail -n +2)
echo "$body" > version/changelog.txt
echo "Tag: v$version"
echo "Version: $version"
echo "Body: $body"
exit 0