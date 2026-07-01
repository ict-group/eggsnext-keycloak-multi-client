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

# -----------------------------------------------------------------------------
# Temi live (sviluppo locale) per WildFly (Keycloak < 17)
#
# In sviluppo, /opt/client-themes è un bind mount READ-ONLY della cartella
# clienti/<client>/themes dell'host. Non possiamo bind-montare direttamente
# /opt/jboss/keycloak/themes: sovrascriverebbe anche base/keycloak/keycloak-preview
# (su WildFly sono cartelle vere dentro l'immagine, non risorse in un jar come
# su Quarkus), e i file dell'host non sono scrivibili dall'utente jboss.
#
# Copiamo quindi ogni tema cliente dentro /opt/jboss/keycloak/themes (di
# proprietà di jboss, quindi scrivibile) e lì applichiamo il fix del parent
# (Dockerfile.legacy lo fa già in build, ma qui rifacciamo lo stesso fix sulla
# copia fresca, per restare aggiornati a ogni riavvio del container).
# -----------------------------------------------------------------------------
if [ -d /opt/client-themes ]; then
    for src in /opt/client-themes/*; do
        [ -d "$src" ] || continue
        theme_name="$(basename "$src")"
        case "$theme_name" in
            base|keycloak|keycloak-preview)
                echo "[WARN] Ignoro tema riservato dall'host: $theme_name"
                continue
                ;;
        esac
        echo "[INFO] Copio tema live dall'host: $theme_name"
        rm -rf "/opt/jboss/keycloak/themes/${theme_name}"
        cp -R "$src" /opt/jboss/keycloak/themes/
    done
fi

for theme in /opt/jboss/keycloak/themes/*; do
    [ -d "$theme" ] || continue
    theme_name="$(basename "$theme")"
    case "$theme_name" in
        base|keycloak|keycloak-preview)
            continue
            ;;
    esac
    for f in "$theme"/login/theme.properties \
             "$theme"/email/theme.properties \
             "$theme"/account/theme.properties \
             "$theme"/admin/theme.properties; do
        [ -f "$f" ] || continue
        sed -i -e 's/^parent=keycloak\.v2$/parent=keycloak/' "$f"
    done
done

exec /opt/jboss/tools/docker-entrypoint.sh "$@"