#!/bin/bash
# Uso: ./test-image.sh papalini 26.6.1

CLIENT_ID=${1:?"\n❌ Devi passare CLIENT_ID. Es: ./test-image.sh papalini 26.6.1"}
KEYCLOAK_VERSION=${2:-26.6.1}
REGISTRY="ghcr.io/ict-group/eggsnext-keycloak-multi-client"

echo "🔄 Pull immagine: $REGISTRY/keycloak-$CLIENT_ID:$KEYCLOAK_VERSION"
docker pull $REGISTRY/keycloak-$CLIENT_ID:$KEYCLOAK_VERSION

echo "🚀 Avvio test con CLIENT_ID=$CLIENT_ID VERSION=$KEYCLOAK_VERSION"
CLIENT_ID=$CLIENT_ID \
KEYCLOAK_VERSION=$KEYCLOAK_VERSION \
docker compose -f docker-compose-test.yml up