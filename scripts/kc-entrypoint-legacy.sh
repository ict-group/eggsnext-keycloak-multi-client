#!/bin/sh
# Wrapper entrypoint per Keycloak WildFly (< 17).
#
# In WildFly il frontend URL si configura con KEYCLOAK_FRONTEND_URL (URL completo con https://).
# KC_HOSTNAME è una variabile Quarkus-only e viene ignorata da WildFly.
# Questo wrapper deriva KEYCLOAK_FRONTEND_URL da KC_HOSTNAME se impostato,
# così i file .env dei clienti usano la stessa variabile per tutte le versioni.

set -e

if [ -n "${KC_HOSTNAME:-}" ]; then
    case "${KC_HOSTNAME}" in
        *localhost*|*127.0.0.1*)
            # TRAPPOLA EVITATA: Se siamo in locale su HTTP, impostare KEYCLOAK_FRONTEND_URL
            # fa credere a Keycloak che la richiesta sia "esterna", forzando l'uso di SSL (HTTPS)
            # e mandando la console di amministrazione in loop infinito.
            echo "[INFO] Rilevato ambiente locale (localhost/127.0.0.1). Salto la configurazione di KEYCLOAK_FRONTEND_URL per evitare loop SSL su HTTP."
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
            # WildFly usa /auth come context root — deve essere incluso nel frontend URL
            base="${base%/auth}"
            export KEYCLOAK_FRONTEND_URL="${base}/auth"
            echo "[INFO] Configurato KEYCLOAK_FRONTEND_URL=${KEYCLOAK_FRONTEND_URL}"
            ;;
    esac
fi

exec /opt/jboss/tools/docker-entrypoint.sh "$@"