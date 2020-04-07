#!/bin/bash --login

set -e

git clone lf-git lf-git-changed

CHANGELOG_FILE="CHANGELOG.md"
VERSION_FILE="VERSION"

COMMIT_URL="https://github.com/pivotal/LicenseFinder/commit/"

TAGS=( "Added" "ADDED" "Fixed" "FIXED" "Changed" "CHANGED" "Deprecated" "DEPRECATED" "Removed" "REMOVED" "Security" "SECURITY" )
CONTRIBUTORS=( "Shane Lattanzio" "Li Tai" "Vikram Yadav" "Mark Fiorvanti" "Serafima Ostrovskaya" "Yoon Jean Kim"  "Tony Wong" "Parv Mital" )

OLD="v$(cat ./lf-release/version)"
VERSION="$(cat semver-version/version)"
VERSION_TAG="v$VERSION"

# Add version title information
LOG=$(echo "# [$VERSION] / $(date +%Y-%m-%d)\n")

cd lf-git-changed

for ((i = 0; i < ${#TAGS[@]}; i++)); do
    if [[ $i -gt 0 ]]; then
        TAG_COMPARE=$(echo "${TAGS[$i]}" | grep -qi "${TAGS[$i - 1]}" && echo same || echo different)
        HEADER_EXISTS=$(echo "$LOG" | grep -qi "${TAGS[$i - 1]}" && echo exists || echo dne)
    fi

    GIT_LOG=$'\n'$(git log "$OLD"...HEAD --pretty=format:"%H%n%s - [%h]($COMMIT_URL%H) - %an%n%n"| grep -E "\[${TAGS[$i]}\] .*" | sort | sed -e "s/\[${TAGS[$i]}\]/\*/g")

    # Only add section information if it has content
    if [[ $i -ne $[${#TAGS[@]}-1] && $GIT_LOG =~ "." && $i -gt 0 && "$TAG_COMPARE" == "same" && "$HEADER_EXISTS" == "exists"  ]]; then
        LOG="$LOG""$GIT_LOG\n"
    elif [[ $GIT_LOG =~ "." ]]; then
        if [[ $i -gt 0 && "$TAG_COMPARE" == "same" && "$HEADER_EXISTS" == "dne" ]]; then
            LOG="$LOG"$'\n'$(echo "### ${TAGS[$i - 1]}")"$GIT_LOG\n"
        else
            LOG="$LOG"$'\n'$(echo "### ${TAGS[$i]}")"$GIT_LOG\n"
        fi
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

# Update version file in git
echo $VERSION > $VERSION_FILE

git config --global user.email $GIT_EMAIL
git config --global user.name $GIT_USERNAME

git add $CHANGELOG_FILE
git add $VERSION_FILE

git commit -m "Update changelog for version: $VERSION"

echo "New version: $VERSION"
echo "Current version: $OLD"

if [ "$VERSION" == "$OLD" ]; then
    echo "Error: Version in VERSION file is identical to latest release on github"
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
