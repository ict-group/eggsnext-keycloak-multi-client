#!/bin/bash
CLIENT_ID=${1:?"
❌ Devi passare CLIENT_ID. Es: ./test-image.sh papalini 26.6.1"}
KEYCLOAK_VERSION=${2:-26.6.1}
REGISTRY="ghcr.io/ict-group/eggsnext-keycloak-multi-client"

# Calcola major version e imposta tutto in base all'architettura
MAJOR=$(echo "$KEYCLOAK_VERSION" | cut -d. -f1)

if [ "$MAJOR" -ge 17 ]; then
  # --- Quarkus (>= 17) ---
  KEYCLOAK_DOCKERFILE=Dockerfile
  KEYCLOAK_THEMES_PATH=/opt/keycloak/themes
  KEYCLOAK_CMD="start-dev --spi-theme-static-max-age=-1 --spi-theme-cache-themes=false --spi-theme-cache-templates=false"
  echo "🐳 Architettura: Quarkus (>= 17)"
else
  # --- WildFly (< 17) ---
  KEYCLOAK_DOCKERFILE=Dockerfile.legacy
  KEYCLOAK_THEMES_PATH=/opt/jboss/keycloak/themes
  KEYCLOAK_CMD="-b 0.0.0.0"
  echo "🐳 Architettura: WildFly (< 17)"
fi

echo "📦 Pull immagine: $REGISTRY/keycloak-$CLIENT_ID:$KEYCLOAK_VERSION"
docker pull $REGISTRY/keycloak-$CLIENT_ID:$KEYCLOAK_VERSION

echo "🚀 Avvio con CLIENT_ID=$CLIENT_ID VERSION=$KEYCLOAK_VERSION"
CLIENT_ID=$CLIENT_ID \
KEYCLOAK_VERSION=$KEYCLOAK_VERSION \
KEYCLOAK_DOCKERFILE=$KEYCLOAK_DOCKERFILE \
KEYCLOAK_THEMES_PATH=$KEYCLOAK_THEMES_PATH \
KEYCLOAK_CMD="$KEYCLOAK_CMD" \
docker compose -f docker-compose-test.yml up