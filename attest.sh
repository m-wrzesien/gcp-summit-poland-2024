#!/bin/bash

set -euo pipefail

PROJECT="esky-gcp-summit-warsaw-2024"
ATTESTOR="attestor"
LOCATION=global
KMS_KEYRING_NAME="attestor-key-ring"
KMS_KEY_NAME="attestor-key"
KMS_KEY_VERSION="1"
IMAGE_WITH_DIGEST="$1"

set -x

gcloud beta container binauthz attestations sign-and-create \
    --project="${PROJECT}" \
    --artifact-url="${IMAGE_WITH_DIGEST}" \
    --attestor="${ATTESTOR}" \
    --attestor-project="${PROJECT}" \
    --keyversion-project="${PROJECT}" \
    --keyversion-location="${LOCATION}" \
    --keyversion-keyring="${KMS_KEYRING_NAME}" \
    --keyversion-key="${KMS_KEY_NAME}" \
    --keyversion="${KMS_KEY_VERSION}"

gcloud container binauthz attestations list\
    --project="${PROJECT}"\
    --attestor="projects/${PROJECT}/attestors/${ATTESTOR}"\
    --artifact-url="${IMAGE_WITH_DIGEST}"