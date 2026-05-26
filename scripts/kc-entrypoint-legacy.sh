#!/bin/sh
# Wrapper entrypoint per Keycloak WildFly (< 17).
#
# In WildFly il frontend URL si configura con KEYCLOAK_FRONTEND_URL (URL completo con https://).
# KC_HOSTNAME è una variabile Quarkus-only e viene ignorata da WildFly.
# Questo wrapper deriva KEYCLOAK_FRONTEND_URL da KC_HOSTNAME se impostato,
# così i file .env dei clienti usano la stessa variabile per tutte le versioni.

set -e

if [ -n "${KC_HOSTNAME:-}" ]; then
    host="${KC_HOSTNAME#https://}"
    host="${host#http://}"
    host="${host%/}"
    export KEYCLOAK_FRONTEND_URL="https://${host}"
fi

exec /opt/jboss/tools/docker-entrypoint.sh "$@"
