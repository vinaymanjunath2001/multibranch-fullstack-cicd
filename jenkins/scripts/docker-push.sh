#!/bin/bash
set -euo pipefail

echo "Logging in to DockerHub..."

# Ensure Docker config directory exists for Jenkins user
mkdir -p /var/lib/jenkins/.docker
export DOCKER_CONFIG=/var/lib/jenkins/.docker

# Secure login (no password in command line)
echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin

echo "Pushing frontend image..."
docker push "$DOCKERHUB_USERNAME/$FRONTEND_IMAGE:$IMAGE_TAG"

echo "Pushing backend image..."
docker push "$DOCKERHUB_USERNAME/$BACKEND_IMAGE:$IMAGE_TAG"

echo "Docker images pushed successfully"
