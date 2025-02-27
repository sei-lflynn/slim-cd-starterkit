#!/bin/bash
set -e

ENV=$1
echo "Deploying to $ENV environment..."

if [ "$ENV" == "staging" ]; then
  kubectl apply -f k8s/staging.yaml
elif [ "$ENV" == "production" ]; then
  kubectl apply -f k8s/production.yaml
else
  echo "Invalid environment specified."
  exit 1
fi

echo "Deployment to $ENV completed successfully!"
