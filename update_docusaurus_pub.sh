#!/bin/bash
#set -x

PAGES_URL=$1
GITHUB_REPOSITORY=$2

PAGES_URL=$(echo "$PAGES_URL" | sed -s "s/https:\/\///")
IFS=/ read -r -d '' ORG REPO < <(printf %s "$GITHUB_REPOSITORY")

document="docusaurus.config.js"

echo "$GITHUB_REPOSITORY"
echo "$PAGES_URL"
echo "$ORG"
echo "$REPO"

sed -i "s/\bbaseUrl:.*/baseUrl: \'\/$REPO\/\',/" $document
sed -i "s/\/github.ibm.com\//\/github.com\//" $document
#sed -i "s/\/github.com\//\/github.ibm.com\//" $document
sed -i "s/\burl:.*/url: \'https:\/\/$PAGES_URL\',/" $document
sed -i "s/\bprojectName:.*/projectName: \'$REPO\',/" $document
sed -i "s/solution-name/$REPO/" $document
sed -i "s/\bonBrokenLinks:.*/onBrokenLinks: \'warn\',/" $document