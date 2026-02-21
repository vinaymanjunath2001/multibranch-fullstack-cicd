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

# Checkout current branch (multibranch automatically checks it out)
git checkout "$BRANCH_NAME"

# Update frontend image tag
sed -i "/frontend:/,/pullPolicy:/s|tag: .*|tag: ${IMAGE_TAG}|" "$VALUES_FILE"

# Update backend image tag
sed -i "/backend:/,/pullPolicy:/s|tag: .*|tag: ${IMAGE_TAG}|" "$VALUES_FILE"

echo "Updated image tags in $VALUES_FILE:"
grep "tag:" "$VALUES_FILE"

# Commit only if file changed
if git diff --quiet; then
  echo "No changes detected. Skipping commit."
  exit 0
fi

git add "$VALUES_FILE"
git commit -m "ci(${BRANCH_NAME}): update image tag to ${IMAGE_TAG}"
git push origin "$BRANCH_NAME"

echo "Helm values updated and pushed successfully"