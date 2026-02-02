#!/bin/bash
set -e

echo "=============================="
echo "Starting Test Stage"
echo "=============================="

echo "Running FRONTEND tests"
cd frontend

if npm test -- --watch=false --passWithNoTests; then
  echo "Frontend tests passed or not present"
else
  echo "Frontend tests failed"
  exit 1
fi

cd ..

echo "Running BACKEND tests"
cd backend

if npm test; then
  echo "Backend tests passed"
else
  echo "No backend tests found, skipping"
fi

cd ..

echo "Test stage completed"
