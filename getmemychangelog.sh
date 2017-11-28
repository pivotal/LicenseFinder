#!/bin/bash

OLD_VERSION=$1
NEW_VERSION=HEAD

TAGS=( "ADDED" "FIXED" "CHANGED" "DEPRECATED" "REMOVED" "SECURITY" )

# git log $OLD_VERSION...$NEW_VERSION --pretty

for i in ${TAGS[@]}
do
	echo "## $i"
    git log v3.0.4...HEAD --pretty=format:"%H%n%b%n%n"| grep -E "\[$i\] .*" | sort | sed -e "s/\[$i\]/\*/g"
done

