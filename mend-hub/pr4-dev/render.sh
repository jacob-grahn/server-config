#!/bin/bash

# Go to the directory where the script is located
cd "$(dirname "$0")"

# Inject image tags for pr4-dev
export CLIENT_WEB_TAG=$(../../scripts/fetch-ghcr-tag.sh 'ghcr.io/jacob-grahn/platform-racing-4-client-web' '.*-main-.*')
export API_TAG=$(../../scripts/fetch-ghcr-tag.sh 'ghcr.io/jacob-grahn/platform-racing-4-api' '.*-main-.*')
cat pr4-dev.template.yaml | envsubst > pr4-dev.rendered.yaml