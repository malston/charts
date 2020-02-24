#!/usr/bin/env bash

set -e
# only exit with zero if all commands of the pipeline exit successfully
set -o pipefail

readonly IMAGE_TAG=v3.0.0-beta.1
readonly IMAGE_REPOSITORY="malston/pks-charts-ci-test-image"

PIVNET_TOKEN="${1:?"Must supply pivnet token"}"

docker build --build-arg pivnet_token="${PIVNET_TOKEN}" -t "${IMAGE_REPOSITORY}:${IMAGE_TAG}" .

docker login
docker tag "${IMAGE_REPOSITORY}:${IMAGE_TAG}" "${IMAGE_REPOSITORY}:${IMAGE_TAG}"
docker push "${IMAGE_REPOSITORY}:${IMAGE_TAG}"
# docker login "https://${HARBOR_HOSTNAME}" --username admin --password "${HARBOR_ADMIN_PASSWORD}"
# docker tag "${IMAGE_REPOSITORY}:${IMAGE_TAG}" "${HARBOR_HOSTNAME}/library/${IMAGE_REPOSITORY}:${IMAGE_TAG}"
# docker push "${HARBOR_HOSTNAME}/library/${IMAGE_REPOSITORY}:${IMAGE_TAG}"
