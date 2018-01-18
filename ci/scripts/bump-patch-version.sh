#!/bin/bash --login

set -e

git clone lf-git lf-git-changed

VERSION="$(ruby -r ./lf-git-changed/lib/license_finder/version.rb -e "puts LicenseFinder::VERSION")"

OLD_PATCH=$(cut -d'.' -f3 <<<"$VERSION")

NEW_PATCH=$(echo $((++OLD_PATCH)))

NEW_VERSION="$(cut -d'.' -f1 -f2 <<<"$VERSION").$NEW_PATCH"

sed -i.bak "s/$VERSION/$NEW_VERSION/g" ./lf-git-changed/lib/license_finder/version.rb

exit 0