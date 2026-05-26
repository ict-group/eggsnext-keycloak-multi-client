#!/bin/sh
# Wrapper entrypoint per Keycloak WildFly (< 17).
#
# In WildFly il frontend URL si configura con KEYCLOAK_FRONTEND_URL.
# KC_HOSTNAME è Quarkus-only e viene ignorata da WildFly.
#
# Regola fondamentale:
# - in locale su localhost/127.0.0.1 NON forzare KEYCLOAK_FRONTEND_URL;
# - in produzione, se KC_HOSTNAME è valorizzato, deriviamo KEYCLOAK_FRONTEND_URL.

set -e

if [ -n "${KC_HOSTNAME:-}" ]; then
    case "${KC_HOSTNAME}" in
        *localhost*|*127.0.0.1*)
            echo "[INFO] Ambiente locale rilevato: ${KC_HOSTNAME}"
            echo "[INFO] Rimuovo KEYCLOAK_FRONTEND_URL per evitare redirect/proxy errati su Keycloak legacy."
            unset KEYCLOAK_FRONTEND_URL
            export PROXY_ADDRESS_FORWARDING="${PROXY_ADDRESS_FORWARDING:-false}"
            ;;
        *)
            case "${KC_HOSTNAME}" in
                http://*|https://*)
                    base="${KC_HOSTNAME%/}"
                    ;;
                *)
                    base="https://${KC_HOSTNAME%/}"
                    ;;
            esac

            base="${base%/auth}"
            export KEYCLOAK_FRONTEND_URL="${base}/auth"
            export PROXY_ADDRESS_FORWARDING="${PROXY_ADDRESS_FORWARDING:-true}"

            echo "[INFO] Configurato KEYCLOAK_FRONTEND_URL=${KEYCLOAK_FRONTEND_URL}"
            echo "[INFO] PROXY_ADDRESS_FORWARDING=${PROXY_ADDRESS_FORWARDING}"
            ;;
    esac
else
    case "${KEYCLOAK_FRONTEND_URL:-}" in
        *localhost*|*127.0.0.1*)
            echo "[INFO] KEYCLOAK_FRONTEND_URL locale rilevato: ${KEYCLOAK_FRONTEND_URL}"
            echo "[INFO] Lo rimuovo per evitare loop della admin console su Keycloak legacy."
            unset KEYCLOAK_FRONTEND_URL
            export PROXY_ADDRESS_FORWARDING="${PROXY_ADDRESS_FORWARDING:-false}"
            ;;
    esac
fi

exec /opt/jboss/tools/docker-entrypoint.sh "$@"