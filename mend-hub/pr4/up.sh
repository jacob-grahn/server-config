#!/bin/bash

# Go to the directory where the script is located
cd "$(dirname "$0")"

# Inject image tags for pr4
export CLIENT_WEB_TAG=$(../scripts/fetch-ghcr-tag.sh 'ghcr.io/jacob-grahn/platform-racing-4-client-web' '.*-release-.*')
export API_TAG=$(../scripts/fetch-ghcr-tag.sh 'ghcr.io/jacob-grahn/platform-racing-4-api' '.*-release-.*')
cat pr4.template.yaml | envsubst > pr4.rendered.yaml

# Start pr4
docker compose \
  -f pr4.rendered.yaml \
  -f pr4.secrets.yaml \
  --project-name pr4 \
  up \
  -d \
  --remove-orphans