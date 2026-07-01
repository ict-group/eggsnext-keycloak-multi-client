#!/bin/bash
set -euo pipefail

CLIENT_ID=${1:?"Devi passare CLIENT_ID. Es: ./test-image.sh cps 11.0.0"}
KEYCLOAK_VERSION=${2:-26.6.1}

if [ ! -d "clienti/${CLIENT_ID}/themes" ]; then
  echo "ERRORE: nessuna cartella clienti/${CLIENT_ID}/themes trovata"
  exit 1
fi

MAJOR=$(echo "$KEYCLOAK_VERSION" | cut -d. -f1)

export CLIENT_ID
export KEYCLOAK_VERSION

if [ "$MAJOR" -ge 17 ]; then
  echo "Architettura: Quarkus >= 17"
  echo "Keycloak:      http://localhost:8080"
  echo "Admin Console: http://localhost:8080/admin"
  export KEYCLOAK_DOCKERFILE=Dockerfile
  export KEYCLOAK_THEMES_VOLUME="./clienti/${CLIENT_ID}/themes:/opt/keycloak/themes"
  export KEYCLOAK_CMD="start-dev --spi-theme-static-max-age=-1 --spi-theme-cache-themes=false --spi-theme-cache-templates=false"
else
  echo "Architettura: WildFly legacy < 17"
  echo "Keycloak:      http://localhost:8080/auth"
  echo "Admin Console: http://localhost:8080/auth/admin"
  export KEYCLOAK_DOCKERFILE=Dockerfile.legacy
  export KEYCLOAK_THEMES_VOLUME="./clienti/${CLIENT_ID}/themes:/opt/jboss/keycloak/themes"
  export KEYCLOAK_CMD="-b 0.0.0.0"
fi

echo "Dockerfile:    ${KEYCLOAK_DOCKERFILE}"
echo "Mailpit:       http://localhost:8025"

docker compose -f docker-compose-test.yml up --build
