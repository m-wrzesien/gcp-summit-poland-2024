#!/bin/bash

set -euo pipefail

REPOSITORY="docker-repo"
REGISTRY="europe-docker.pkg.dev/${PROJECT}/${REPOSITORY}"
BACKEND_IMAGE="${REGISTRY}/hello-app"
BACKEND_VULNERABLE_IMAGE="${BACKEND_IMAGE}:vulnerable"
BACKEND_SECURE_IMAGE="${BACKEND_IMAGE}:secure"
FRONTEND_IMAGE="${REGISTRY}/nginx"
FRONTEND_VULNERABLE_IMAGE="${FRONTEND_IMAGE}:vulnerable"
FRONTEND_SECURE_IMAGE="${FRONTEND_IMAGE}:secure"

getImageDigest() {
    image=$1
    tag=$2
    docker images --digests "$image" | grep "$tag" | awk '{print $3}'
}

set -x

cd apps/src
cd hello-app

docker build -t "$BACKEND_VULNERABLE_IMAGE" -f vulnerable.Dockerfile .
docker push "$BACKEND_VULNERABLE_IMAGE"

echo "Do you want to continue?"
read -rn 1

docker build -t "$BACKEND_SECURE_IMAGE" -f secure.Dockerfile .
docker push "$BACKEND_SECURE_IMAGE"

echo "Do you want to continue?"
read -rn 1

cd -

cd nginx

docker build -t "$FRONTEND_VULNERABLE_IMAGE" -f vulnerable.Dockerfile .
docker push "$FRONTEND_VULNERABLE_IMAGE"

echo "Do you want to continue?"
read -rn 1

docker build -t "$FRONTEND_SECURE_IMAGE" -f secure.Dockerfile .
docker push "$FRONTEND_SECURE_IMAGE"

set +x

cd -

echo "#### Builded images ####"
echo "$BACKEND_VULNERABLE_IMAGE@$(getImageDigest "$BACKEND_IMAGE" vulnerable)"
echo "$BACKEND_SECURE_IMAGE@$(getImageDigest "$BACKEND_IMAGE" secure)"
echo "$FRONTEND_VULNERABLE_IMAGE@$(getImageDigest "$FRONTEND_IMAGE" vulnerable)"
echo "$FRONTEND_SECURE_IMAGE@$(getImageDigest "$FRONTEND_IMAGE" secure)"

echo "Check artifact registy https://console.cloud.google.com/artifacts/docker/${PROJECT}/europe/${REPOSITORY}?project=${PROJECT}"