#!/bin/bash
set -e

echo "=============================="
echo "Updating Helm values file"
echo "=============================="

# Required vars
: "${BUILD_NUMBER:?Missing BUILD_NUMBER}"
: "${GIT_USERNAME:?Missing GIT_USERNAME}"
: "${BRANCH_NAME:?Missing BRANCH_NAME}"
: "${IMAGE_TAG:?Missing IMAGE_TAG}"

echo "Branch: $BRANCH_NAME"
echo "Image Tag: $IMAGE_TAG"

# Select correct values file based on branch
if [ "$BRANCH_NAME" == "dev" ]; then
  VALUES_FILE="helm/fullstack-app/values-dev.yaml"
elif [ "$BRANCH_NAME" == "staging" ]; then
  VALUES_FILE="helm/fullstack-app/values-staging.yaml"
elif [ "$BRANCH_NAME" == "main" ]; then
  VALUES_FILE="helm/fullstack-app/values-prod.yaml"
else
  echo "Branch not configured for deployment. Skipping."
  exit 0
fi

echo "Updating file: $VALUES_FILE"

# Configure git identity
git config user.name "$GIT_USERNAME"
git config user.email "ci-bot@jenkins.local"

git fetch origin
git checkout "$BRANCH_NAME"

git reset --hard origin/$BRANCH_NAME
git clean -fd

git pull origin "$BRANCH_NAME"

echo "Updating image tag to ${IMAGE_TAG}"

sed -i "/frontend:/,/pullPolicy:/s|tag: .*|tag: ${IMAGE_TAG}|" "$VALUES_FILE"
sed -i "/backend:/,/pullPolicy:/s|tag: .*|tag: ${IMAGE_TAG}|" "$VALUES_FILE"

git add "$VALUES_FILE"

if git diff --cached --quiet; then
  echo "No changes detected"
  exit 0
fi

git commit -m "ci(${BRANCH_NAME}): update image tag to ${IMAGE_TAG}"

git push origin "$BRANCH_NAME"