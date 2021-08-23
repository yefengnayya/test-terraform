#!/bin/bash

if [ -z "$ECR_REGISTRY" ]; then
  echo "ECR_REGISTRY must be set!"
  exit 1
fi
if [ -z "$REPO_NAME" ]; then
  echo "REPO_NAME must be set!"
  exit 1
fi

aws ecr describe-repositories --repository-names ${REPO_NAME} || aws ecr create-repository --repository-name ${REPO_NAME}

ECR="${ECR_REGISTRY}/${REPO_NAME}"

docker pull $ECR:latest || true

docker build --load \
  -t ${ECR}:latest \
  --cache-from ${ECR}:latest \
  --build-arg BUILDKIT_INLINE_CACHE=1 \
  .

DIGEST=$(docker inspect ${ECR}:latest | jq -r '.[0].Id' | sed 's/sha256://')

docker tag ${ECR}:latest ${ECR}:${DIGEST}

docker push ${ECR}:latest

docker push ${ECR}:${DIGEST}

echo "::set-output name=image::${ECR}:${DIGEST}"
