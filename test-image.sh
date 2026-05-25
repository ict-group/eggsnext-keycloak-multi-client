#!/bin/bash
CLIENT_ID=${1:?"
❌ Devi passare CLIENT_ID. Es: ./test-image.sh papalini 26.6.1"}
KEYCLOAK_VERSION=${2:-26.6.1}
REGISTRY="ghcr.io/ict-group/eggsnext-keycloak-multi-client"

MAJOR=$(echo "$KEYCLOAK_VERSION" | cut -d. -f1)

if [ "$MAJOR" -ge 17 ]; then
  KEYCLOAK_DOCKERFILE=Dockerfile
  KEYCLOAK_THEMES_PATH=/opt/keycloak/themes
  KEYCLOAK_CMD="start-dev --spi-theme-static-max-age=-1 --spi-theme-cache-themes=false --spi-theme-cache-templates=false"
  # Quarkus: monta i temi dal disco (utile in dev per hot-reload)
  KEYCLOAK_THEMES_VOLUME="./clienti/${CLIENT_ID}/themes:${KEYCLOAK_THEMES_PATH}"
  echo "🐳 Architettura: Quarkus (>= 17)"
else
  KEYCLOAK_DOCKERFILE=Dockerfile.legacy
  KEYCLOAK_THEMES_PATH=/opt/jboss/keycloak/themes
  KEYCLOAK_CMD="-b 0.0.0.0"
  # WildFly legacy: NON montare il volume — i temi sono già nell'immagine
  # e il volume sovrascriberebbe il fix del parent=base→keycloak
  KEYCLOAK_THEMES_VOLUME="/dev/null:${KEYCLOAK_THEMES_PATH}/DO_NOT_MOUNT"
  echo "🐳 Architettura: WildFly (< 17) — temi dall'immagine (no volume mount)"
fi

echo "📦 Pull immagine: $REGISTRY/keycloak-$CLIENT_ID:$KEYCLOAK_VERSION"
docker pull $REGISTRY/keycloak-$CLIENT_ID:$KEYCLOAK_VERSION

echo "🚀 Avvio con CLIENT_ID=$CLIENT_ID VERSION=$KEYCLOAK_VERSION"
CLIENT_ID=$CLIENT_ID \
KEYCLOAK_VERSION=$KEYCLOAK_VERSION \
KEYCLOAK_DOCKERFILE=$KEYCLOAK_DOCKERFILE \
KEYCLOAK_THEMES_PATH=$KEYCLOAK_THEMES_PATH \
KEYCLOAK_THEMES_VOLUME="$KEYCLOAK_THEMES_VOLUME" \
KEYCLOAK_CMD="$KEYCLOAK_CMD" \
docker compose -f docker-compose-test.yml up