#!/bin/sh
# Wrapper entrypoint per Keycloak Quarkus (>= 17).
#
# Normalizza KC_HOSTNAME in base alla versione:
#   v17-24 (hostname v1): solo il nome host, senza protocollo
#   v25+   (hostname v2): URL completo con https://
#
# Regole:
#   http://...   → preservato invariato (sviluppo locale con HTTP esplicito)
#   https://...  + v17-24 → stripping del protocollo (fix bug CSP http://https://)
#   https://...  + v25+   → invariato (già corretto)
#   host-solo    + v25+   → aggiunge https://
#   host-solo    + v17-24 → invariato (già corretto)

set -e

_normalize() {
    raw="$1"
    major="$2"
    case "$raw" in
        http://*)
            printf '%s' "$raw"
            ;;
        https://*)
            if [ "$major" -ge 25 ]; then
                printf '%s' "$raw"
            else
                host="${raw#https://}"
                host="${host%/}"
                printf '%s' "$host"
            fi
            ;;
        *)
            host="${raw%/}"
            if [ "$major" -ge 25 ]; then
                printf '%s' "https://${host}"
            else
                printf '%s' "$host"
            fi
            ;;
    esac
}

MAJOR="$(echo "${KEYCLOAK_VERSION:-0.0.0}" | cut -d. -f1)"

if [ -n "${KC_HOSTNAME:-}" ]; then
    export KC_HOSTNAME="$(_normalize "$KC_HOSTNAME" "$MAJOR")"
fi

if [ -n "${KC_HOSTNAME_ADMIN:-}" ]; then
    export KC_HOSTNAME_ADMIN="$(_normalize "$KC_HOSTNAME_ADMIN" "$MAJOR")"
fi

exec /opt/keycloak/bin/kc.sh "$@"
