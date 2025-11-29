#!/bin/bash

set -e  # Exit on error

# Configuration
# Change YOUR_GITHUB_USERNAME to your actual GitHub username
REGISTRY="ghcr.io/$GITHUB_USERNAME"
SHA_TAG="sha-$(git rev-parse --short HEAD)"

echo "Building and pushing Docker images..."
echo "SHA: $SHA_TAG"
echo ""

# Build and push proposer-eigenda
echo "==> Building proposer-eigenda..."
docker build -f fault-proof/Dockerfile.proposer.eigenda \
  -t ${REGISTRY}/proposer-eigenda:latest \
  -t ${REGISTRY}/proposer-eigenda:${SHA_TAG} \
  .

echo "==> Pushing proposer-eigenda..."
docker push ${REGISTRY}/proposer-eigenda:latest
docker push ${REGISTRY}/proposer-eigenda:${SHA_TAG}

echo ""

# Build and push challenger
echo "==> Building challenger..."
docker build -f fault-proof/Dockerfile.challenger \
  -t ${REGISTRY}/challenger:latest \
  -t ${REGISTRY}/challenger:${SHA_TAG} \
  .

echo "==> Pushing challenger..."
docker push ${REGISTRY}/challenger:latest
docker push ${REGISTRY}/challenger:${SHA_TAG}

echo ""
echo "✅ All images pushed successfully!"
echo ""
echo "Images available at:"
echo "  - ${REGISTRY}/proposer-eigenda:latest"
echo "  - ${REGISTRY}/proposer-eigenda:${SHA_TAG}"
echo "  - ${REGISTRY}/challenger:latest"
echo "  - ${REGISTRY}/challenger:${SHA_TAG}"
