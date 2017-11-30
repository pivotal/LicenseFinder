#!/bin/bash --login

set -e

CHANGELOG_FILE="CHANGELOG.md"
COMMIT_URL="https://github.com/pivotal/LicenseFinder/commit/"

TAGS=( "Added" "Fixed" "Changed" "Deprecated" "Removed" "Security" )
CONTRIBUTORS=( "Shane Lattanzio" "Daniil Kouznetsov" "Andy Shen" "Li Sheng Tai" "Ryan Collins" "Vikram Yadav" )

OLD="v$(cat ./lf-release/version)"
VERSION="$(ruby -r ./lf-git/lib/license_finder/version.rb -e "puts LicenseFinder::VERSION")"
VERSION_TAG="v$VERSION"

# Add version title information
LOG=$(echo "# [$VERSION] / $(date +%Y-%m-%d)\n")

cd lf-git
BRANCH=$(git branch | grep \* | sed "s/* //g")

for i in ${TAGS[@]}; do
    GIT_LOG=$'\n'$(git log $OLD...HEAD --pretty=format:"%H%n%b - [%h]($COMMIT_URL%H) - %an%n%n"| grep -E -i "\[$i\] .*" | sort | sed -e "s/\[$i\]/\*/g")

    # Only add section information if it has content
    if [[ $GIT_LOG =~ "." ]]; then
        LOG="$LOG"$'\n'$(echo "### $i")"$GIT_LOG\n"
    fi
done

# Strip Pivotal contributors
for ((i = 0; i < ${#CONTRIBUTORS[@]}; i++)); do
    LOG=$(echo "$LOG" | sed -e "s/-* ${CONTRIBUTORS[$i]}//g")
done

# Prepend new version information at the top of the file
echo -e "$LOG\n$(cat $CHANGELOG_FILE)" > $CHANGELOG_FILE

# Append version hyperlink to the end of the file
echo -e "[$VERSION]: https://github.com/pivotal/LicenseFinder/compare/$OLD...$VERSION_TAG" >> $CHANGELOG_FILE

git config --global user.email $GIT_EMAIL
git config --global user.name $GIT_USERNAME

git add $CHANGELOG_FILE
git commit -m "Update changelog for version: $VERSION"
git push origin $BRANCH

echo "New version: $VERSION"
echo "Current version: $OLD"

if [ "$VERSION" == "$OLD" ]; then
    echo "Error: Version in version.rb is identical to latest release on github"
    exit 1
fi

body=$(cat "$CHANGELOG_FILE" | sed -n "/# \[$VERSION\]/,/# \[[\d\.]*/p" | sed '$d' | tail -n +2)

echo "$VERSION_TAG" > ../version/tag.txt
echo "$VERSION" > ../version/version.txt
echo "$body" > ../version/changelog.txt

echo "Tag: $VERSION_TAG"
echo "Version: $VERSION"
echo "Body: $body"

exit 0
