#!/bin/bash
set -euo pipefail

echo "=============================="
echo "Starting Test Stage"
echo "=============================="

# Ensure npm cache is Jenkins-owned
export NPM_CONFIG_CACHE=/var/lib/jenkins/.npm
export CI=true
mkdir -p "$NPM_CONFIG_CACHE"

echo "Running FRONTEND tests"
cd frontend

# Prevent permission & stale artifacts
rm -rf node_modules/.cache || true

# Frontend tests (CI safe)
npm test -- --watch=false --passWithNoTests

cd ..

echo "Running BACKEND tests"
cd backend

# Check if test script exists
if npm run | grep -q "test"; then
  npm test
else
  echo "No backend tests defined, skipping"
fi

cd ..

echo "Test stage completed successfully"
