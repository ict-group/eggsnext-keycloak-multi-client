#!/bin/bash
set -euo pipefail

CLIENT_ID=${1:?"Devi passare CLIENT_ID. Es: ./test-compose-ghcr.sh cps 11.0.0"}
KEYCLOAK_VERSION=${2:-26.6.1}

MAJOR=$(echo "$KEYCLOAK_VERSION" | cut -d. -f1)

export CLIENT_ID
export KEYCLOAK_VERSION
export REGISTRY_PREFIX="ghcr.io/ict-group/eggsnext-keycloak-multi-client/"

if [ "$MAJOR" -ge 17 ]; then
  echo "Architettura: Quarkus >= 17"
  echo "Keycloak: http://localhost:8080/admin/"
  export KEYCLOAK_CMD="start-dev"
else
  echo "Architettura: WildFly legacy < 17"
  echo "Keycloak: http://localhost:8080/auth/admin/"
  export KEYCLOAK_CMD="-b 0.0.0.0"
fi

echo "Mailpit: http://localhost:8025"

docker compose -f docker-compose-test-ghcr.yml up