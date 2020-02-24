#!/usr/bin/env bash

# Copyright 2018 The Kubernetes Authors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -o errexit
set -o nounset
set -o pipefail

chart="${1:?"Helm chart name required"}"
pks_url="${2:-${PKS_URL}}"
pks_username="${3:-${PKS_USERNAME}}"
pks_password="${4:-${PKS_PASSWORD}}"

readonly IMAGE_TAG=v3.0.0-beta.1
readonly IMAGE_REPOSITORY="malston/pks-charts-ci-test-image"
readonly REPO_ROOT="${REPO_ROOT:-$(git rev-parse --show-toplevel)}"
readonly BUILD_ID="${BUILD_ID:-$(git rev-parse HEAD | cut -c 1-8 )}"

main() {
	local chart="${1}"
	local pks_url="${2}"
	local pks_username="${3}"
	local pks_password="${4}"
	# cd "$__CWD"

    local config_container_id
    config_container_id=$(docker run -ti -d \
        -v "$REPO_ROOT:/workdir" --workdir=/workdir \
        -e "CT_BUILD_ID=$BUILD_ID" \
        "$IMAGE_REPOSITORY:$IMAGE_TAG" cat)

    # shellcheck disable=SC2064
    trap "docker rm -f $config_container_id" EXIT

	docker exec "$config_container_id" cd "$chart" && helm dep update && cd -

    docker exec "$config_container_id" pks login -a \
		"${pks_url}" \
		--skip-ssl-validation \
		-u "${pks_username}" \
		-p "${pks_password}"
    docker exec "$config_container_id" pks get-credentials cluster01
    docker exec "$config_container_id" kubectl cluster-info
    docker exec "$config_container_id" ct lint-and-install --config test/ct.yaml

    echo "Done Testing!"
}

main "${chart}"
