#!/bin/bash
set -e

echo "=============================="
echo "Updating Helm values.yaml"
echo "=============================="

# Required vars (safe check)
: "${BUILD_NUMBER:?Missing BUILD_NUMBER}"
: "${GIT_USERNAME:?Missing GIT_USERNAME}"

IMAGE_TAG="${BUILD_NUMBER}"
VALUES_FILE="helm/fullstack-app/values.yaml"

echo "Using image tag: $IMAGE_TAG"

# Configure git identity
git config user.name "$GIT_USERNAME"
git config user.email "ci-bot@jenkins.local"

# Ensure main branch exists locally
git fetch origin main
git checkout -B main origin/main

# Update ONLY the first occurrence of image tag
#sed -i "0,/tag:/s|tag: .*|tag: ${IMAGE_TAG}|" "$VALUES_FILE"
# Update frontend tag
sed -i "/frontend:/,/pullPolicy:/s|tag: .*|tag: ${IMAGE_TAG}|" "$VALUES_FILE"

# Update backend tag
sed -i "/backend:/,/pullPolicy:/s|tag: .*|tag: ${IMAGE_TAG}|" "$VALUES_FILE"

echo "Updated values.yaml:"
grep "tag:" "$VALUES_FILE"

# Commit only if file changed
if git diff --quiet; then
  echo "No changes detected in values.yaml, skipping commit"
  exit 0
fi

git add "$VALUES_FILE"
git commit -m "ci: update image tag to ${IMAGE_TAG}"
git push origin main

echo "Helm values updated and pushed successfully"
