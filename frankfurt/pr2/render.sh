#!/bin/bash

# Go to the directory where the script is located
cd "$(dirname "$0")"

# Inject image tags
export MULTI_TAG=$(../../scripts/fetch-ghcr-tag.sh 'ghcr.io/jacob-grahn/platform-racing-2-multi' '.*-main-.*')
cat pr2.template.yaml | envsubst > pr2.rendered.yaml