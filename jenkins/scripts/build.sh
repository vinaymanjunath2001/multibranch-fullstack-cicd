#!/bin/bash
set -euo pipefail

echo "=============================="
echo "Starting Build Stage"
echo "=============================="

# Use Jenkins-owned npm cache
export NPM_CONFIG_CACHE=/var/lib/jenkins/.npm
mkdir -p "$NPM_CONFIG_CACHE"

echo "Building FRONTEND"
cd frontend

# Clean old artifacts (prevents permission issues)
rm -rf node_modules .cache || true

if [ -f package-lock.json ]; then
  npm ci
else
  npm install
fi

npm run build
cd ..

echo "Building BACKEND"
cd backend

rm -rf node_modules .cache || true

if [ -f package-lock.json ]; then
  npm ci
else
  npm install
fi

cd ..

echo "Build completed successfully"
