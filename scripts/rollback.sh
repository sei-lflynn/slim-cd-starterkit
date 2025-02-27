#!/bin/bash
set -e

echo "Rolling back to the last stable deployment..."
kubectl rollout undo deployment/slim-cd-app
echo "Rollback completed successfully!"
