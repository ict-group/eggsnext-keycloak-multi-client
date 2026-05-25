#!/bin/bash
CLIENT_ID=${1:?"
❌ Devi passare CLIENT_ID. Es: ./test-image.sh papalini 26.6.1"}
KEYCLOAK_VERSION=${2:-26.6.1}
REGISTRY="ghcr.io/ict-group/eggsnext-keycloak-multi-client"

# Sceglie il Dockerfile in base alla major version
MAJOR=$(echo "$KEYCLOAK_VERSION" | cut -d. -f1)
if [ "$MAJOR" -ge 17 ]; then
  KEYCLOAK_DOCKERFILE=Dockerfile
  echo "🐳 Architettura: Quarkus (>= 17) → $KEYCLOAK_DOCKERFILE"
else
  KEYCLOAK_DOCKERFILE=Dockerfile.legacy
  echo "🐳 Architettura: WildFly (< 17) → $KEYCLOAK_DOCKERFILE"
fi

echo "📦 Pull immagine: $REGISTRY/keycloak-$CLIENT_ID:$KEYCLOAK_VERSION"
docker pull $REGISTRY/keycloak-$CLIENT_ID:$KEYCLOAK_VERSION

echo "🚀 Avvio test con CLIENT_ID=$CLIENT_ID VERSION=$KEYCLOAK_VERSION"
CLIENT_ID=$CLIENT_ID \
KEYCLOAK_VERSION=$KEYCLOAK_VERSION \
KEYCLOAK_DOCKERFILE=$KEYCLOAK_DOCKERFILE \
docker compose -f docker-compose-test.yml up