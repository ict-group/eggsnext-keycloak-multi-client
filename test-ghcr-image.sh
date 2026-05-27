#!/bin/bash
set -euo pipefail

CLIENT_ID=${1:?"Devi passare CLIENT_ID. Es: ./test-ghcr-image.sh cps 11.0.0 13"}
KEYCLOAK_VERSION=${2:-26.6.1}
POSTGRES_VERSION=${3:-${POSTGRES_VERSION:-16}}

MAJOR=$(echo "$KEYCLOAK_VERSION" | cut -d. -f1)

export CLIENT_ID
export KEYCLOAK_VERSION
export POSTGRES_VERSION
export REGISTRY_PREFIX="ghcr.io/ict-group/eggsnext-keycloak-multi-client/"

if [ "$MAJOR" -ge 17 ]; then
  echo "Architettura: Quarkus >= 17"
  echo "Keycloak: http://localhost:8080/admin/"
  export KEYCLOAK_CMD="start-dev"
else
  echo "Architettura: WildFly legacy < 17"
  echo "Keycloak: http://localhost:8080/auth/admin/"
  export KEYCLOAK_CMD="-b 0.0.0.0 -c standalone.xml"
fi

echo "Postgres version: ${POSTGRES_VERSION}"
echo "Mailpit: http://localhost:8025"

docker compose -f docker-compose-test-ghcr.yml up