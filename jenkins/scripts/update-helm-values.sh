#!/bin/bash
set -euo pipefail

echo "=============================="
echo "Updating Helm values.yaml"
echo "=============================="

: "${BUILD_NUMBER:?Missing BUILD_NUMBER}"
: "${GIT_USERNAME:?Missing GIT_USERNAME}"
: "${GIT_EMAIL:?Missing GIT_EMAIL}"

IMAGE_TAG="v1.0.${BUILD_NUMBER}"
VALUES_FILE="helm/fullstack-app/values.yaml"

echo "Using image tag: $IMAGE_TAG"

# Configure git identity
git config user.name "$GIT_USERNAME"
git config user.email "$GIT_EMAIL"

# Ensure main branch exists locally (CI safe)
git fetch origin main
git checkout -B main origin/main

# Update ONLY the image tag (first occurrence)
sed -i "0,/tag:/s|tag: .*|tag: ${IMAGE_TAG}|" "$VALUES_FILE"

echo "Updated values.yaml:"
grep "tag:" "$VALUES_FILE"

# Commit only if there are changes
if git diff --quiet; then
  echo "No changes detected in values.yaml, skipping commit"
  exit 0
fi

git add "$VALUES_FILE"
git commit -m "ci: update image tag to ${IMAGE_TAG}"
git push origin main

echo "Helm values updated and pushed successfully"
