#!/bin/bash

# This script should be set as cron job
# Usage:
#   ./run_z3_branch_as_cron.sh <repo_url> <branch> \
#         <command_name> <TARGET> <BENCHMARK>
#   <BENCHMARK> should contain no '/' at its end

REPO_URL=$1
BRANCH=$2
COMMAND_NAME=$3
TARGET=$5
BENCHMARK_TARGET=$6

SCRIPT_DIR="$( cd ${BASH_SOURCE[0]%/*} ; echo $PWD )"
source "${SCRIPT_DIR}/../scripts/ci_defaults.sh"
set -x
set -e
set -o pipefail

# Build an image with <repo_url> <branch> installed
BUILD_OPTS=()
BUILD_OPTS+=("--build-arg" "SCRIPT='install_z3_branch.sh'")
BUILD_OPTS+=("--build-arg" "SCRIPT_ARG='${REPO_URL} ${BRANCH}")
TARGET_IMAGE="${TARGET}:16.04"

Z3_DOCKER_FILE="${DOCKER_FILE_DIR}/build_single_script.Dockerfile"
docker build \
  -m 4g \
  -f "${Z3_DOCKER_FILE}" \
  -t "${TARGET_IMAGE}" \
  "--build-arg DOCKER_IMAGE_BASE=${BASE_IMAGE_NAME}"
  "${BUILD_OPTS[@]}" \
  .

echo \
  "$(docker run --rm -a STDOUT ${TARGET_IMAGE} \
  ${BENCHMARK_PATH}/ci-run.sh ${TARGET} ${BENCHMARK_TARGET})" \
  > "${OUTPUT_DIR}/${TARGET}.${BENCHMARK_TARGET}.log"

docker -rmi ${TARGET_IMAGE} 