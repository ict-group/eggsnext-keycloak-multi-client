# =============================================================================
# KEYCLOAK MULTI-CLIENT DOCKERFILE — Quarkus / Moderno (Keycloak >= 17)
#
# Usa questo file per Keycloak 17+.
# Path moderno: /opt/keycloak
#
# Note importanti:
# - Copia SOLO i temi cliente, senza mai sovrascrivere i temi di sistema:
#   base, keycloak, keycloak-preview.
# - Le estensioni/provider NON vengono copiate di default, perché non sono
#   compatibili tra tutte le versioni Keycloak.
#   Abilitarle solo con: --build-arg INCLUDE_EXTENSIONS=true
# =============================================================================

ARG KEYCLOAK_VERSION=26.6.1

FROM quay.io/keycloak/keycloak:${KEYCLOAK_VERSION} AS builder

ARG INCLUDE_EXTENSIONS=false

COPY --chown=keycloak:keycloak base /tmp/base

RUN set -eux; \
    mkdir -p /opt/keycloak/providers; \
    if [ "${INCLUDE_EXTENSIONS}" = "true" ] && [ -d /tmp/base/extensions ] && [ "$(find /tmp/base/extensions -mindepth 1 -maxdepth 1 | wc -l)" -gt 0 ]; then \
        echo "Copying custom providers/extensions for Quarkus Keycloak"; \
        cp -R /tmp/base/extensions/* /opt/keycloak/providers/; \
    else \
        echo "Skipping providers/extensions. Set INCLUDE_EXTENSIONS=true to enable them."; \
    fi; \
    /opt/keycloak/bin/kc.sh build; \
    rm -rf /tmp/base

FROM quay.io/keycloak/keycloak:${KEYCLOAK_VERSION}

ARG CLIENT_ID
ARG INCLUDE_EXTENSIONS=false

COPY --from=builder --chown=keycloak:keycloak /opt/keycloak/lib/quarkus/ /opt/keycloak/lib/quarkus/
COPY --from=builder --chown=keycloak:keycloak /opt/keycloak/providers/ /opt/keycloak/providers/
COPY --chown=keycloak:keycloak clienti /tmp/clienti

RUN set -eux; \
    THEME_ROOT="/opt/keycloak/themes"; \
    mkdir -p "${THEME_ROOT}"; \
    copy_theme() { \
        src="$1"; \
        name="$(basename "$src")"; \
        case "$name" in \
            base|keycloak|keycloak-preview) \
                echo "ERROR: refusing to copy reserved Keycloak system theme: $name"; \
                exit 1; \
                ;; \
        esac; \
        echo "Copying theme: $src -> ${THEME_ROOT}/$name"; \
        cp -R "$src" "${THEME_ROOT}/"; \
    }; \
    if [ -z "${CLIENT_ID:-}" ]; then \
        echo "ERROR: CLIENT_ID is required. Example: --build-arg CLIENT_ID=cps"; \
        exit 1; \
    fi; \
    if [ "${CLIENT_ID}" = "all" ] || [ "${CLIENT_ID}" = "all-themes" ]; then \
        echo "Building image with ALL client themes"; \
        found=0; \
        for theme_dir in /tmp/clienti/*/themes/*; do \
            if [ -d "$theme_dir" ]; then \
                found=1; \
                copy_theme "$theme_dir"; \
            fi; \
        done; \
        if [ "$found" = "0" ]; then \
            echo "ERROR: no themes found under /tmp/clienti/*/themes/*"; \
            exit 1; \
        fi; \
    else \
        echo "Building single client image: ${CLIENT_ID}"; \
        if [ ! -d "/tmp/clienti/${CLIENT_ID}/themes" ]; then \
            echo "ERROR: themes folder not found: /tmp/clienti/${CLIENT_ID}/themes"; \
            exit 1; \
        fi; \
        found=0; \
        for theme_dir in /tmp/clienti/${CLIENT_ID}/themes/*; do \
            if [ -d "$theme_dir" ]; then \
                found=1; \
                copy_theme "$theme_dir"; \
            fi; \
        done; \
        if [ "$found" = "0" ]; then \
            echo "ERROR: no theme folders found for CLIENT_ID=${CLIENT_ID}"; \
            exit 1; \
        fi; \
    fi; \
    rm -rf /tmp/clienti; \
    find "${THEME_ROOT}" -mindepth 1 -maxdepth 1 -type d -print

ENV KC_HTTP_ENABLED=true
ENV KC_HOSTNAME_STRICT=false
ENV KC_SPI_THEME_STATIC_MAX_AGE=-1
ENV KC_SPI_THEME_CACHE_THEMES=false
ENV KC_SPI_THEME_CACHE_TEMPLATES=false

# Valori comodi per sviluppo locale. In produzione sovrascrivili con env/secrets.
ENV KEYCLOAK_ADMIN=admin
ENV KEYCLOAK_ADMIN_PASSWORD=admin

EXPOSE 8080

ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]
CMD ["start", "--optimized"]