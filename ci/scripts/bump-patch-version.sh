#!/bin/bash --login

set -e

git clone lf-git lf-git-changed

VERSION_FILE="./lf-git-changed/lib/license_finder/version.rb"

VERSION="$(ruby -r "$VERSION_FILE" -e "puts LicenseFinder::VERSION")"

OLD_PATCH=$(cut -d'.' -f3 <<<"$VERSION")

NEW_PATCH=$(echo $((++OLD_PATCH)))

NEW_VERSION="$(cut -d'.' -f1,2 <<<"$VERSION").$NEW_PATCH"

sed -i.bak "s/$VERSION/$NEW_VERSION/g" "$VERSION_FILE"

cd lf-git-changed
git config --global user.email $GIT_EMAIL
git config --global user.name $GIT_USERNAME

git add "lib/license_finder/version.rb"
git commit -m "Update patch version to: $NEW_VERSION"

exit 0