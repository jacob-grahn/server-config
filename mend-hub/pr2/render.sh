#!/bin/bash

# Go to the directory where the script is located
cd "$(dirname "$0")"

# Inject image tags for pr4
export HTTP_TAG=$(../scripts/fetch-ghcr-tag.sh 'ghcr.io/jacob-grahn/platform-racing-2-http' '.*-main-.*')
export MULTI_TAG=$(../scripts/fetch-ghcr-tag.sh 'ghcr.io/jacob-grahn/platform-racing-2-multi' '.*-main-.*')
cat pr2.template.yaml | envsubst > pr2.rendered.yaml