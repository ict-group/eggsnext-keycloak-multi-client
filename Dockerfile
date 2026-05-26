# =============================================================================
# KEYCLOAK MULTI-CLIENT DOCKERFILE — Modern / Quarkus (Keycloak >= 17)
# Compatibile con Keycloak 17+ fino alle versioni moderne Quarkus.
# =============================================================================

ARG KEYCLOAK_VERSION=26.6.1

FROM quay.io/keycloak/keycloak:${KEYCLOAK_VERSION} AS builder
ARG KEYCLOAK_VERSION

ARG INCLUDE_EXTENSIONS=false

COPY --chown=keycloak:keycloak base /tmp/base

RUN set -eu; \
    mkdir -p /opt/keycloak/providers; \
    if [ "${INCLUDE_EXTENSIONS}" = "true" ] && [ -d /tmp/base/extensions ]; then \
        echo "Copying custom providers/extensions for Quarkus Keycloak"; \
        copied_ext=0; \
        for ext in /tmp/base/extensions/*; do \
            if [ -e "$ext" ]; then \
                cp -R "$ext" /opt/keycloak/providers/; \
                copied_ext=1; \
            fi; \
        done; \
        if [ "$copied_ext" = "0" ]; then \
            echo "No files found in /tmp/base/extensions"; \
        fi; \
    else \
        echo "Skipping providers/extensions. Set INCLUDE_EXTENSIONS=true to enable them."; \
    fi; \
    /opt/keycloak/bin/kc.sh build; \
    rm -rf /tmp/base

FROM quay.io/keycloak/keycloak:${KEYCLOAK_VERSION}

ARG KEYCLOAK_VERSION
ARG CLIENT_ID
ENV KEYCLOAK_VERSION=${KEYCLOAK_VERSION}

COPY --from=builder --chown=keycloak:keycloak /opt/keycloak/lib/quarkus/ /opt/keycloak/lib/quarkus/
COPY --from=builder --chown=keycloak:keycloak /opt/keycloak/providers/ /opt/keycloak/providers/
COPY --chown=keycloak:keycloak clienti /tmp/clienti

RUN set -eu; \
    echo "CLIENT_ID=${CLIENT_ID:-}"; \
    if [ -z "${CLIENT_ID:-}" ]; then \
        echo "ERROR: CLIENT_ID is required. Example: --build-arg CLIENT_ID=cps"; \
        exit 1; \
    fi; \
    THEME_ROOT="/opt/keycloak/themes"; \
    mkdir -p "${THEME_ROOT}"; \
    copied_theme=0; \
    if [ "${CLIENT_ID}" = "all" ] || [ "${CLIENT_ID}" = "all-themes" ]; then \
        echo "Building image with ALL client themes"; \
        for theme_dir in /tmp/clienti/*/themes/*; do \
            if [ -d "$theme_dir" ]; then \
                theme_name="${theme_dir##*/}"; \
                case "$theme_name" in \
                    base|keycloak|keycloak-preview) \
                        echo "ERROR: refusing to copy reserved Keycloak system theme: $theme_name"; \
                        exit 1; \
                        ;; \
                esac; \
                echo "Copying theme: $theme_name"; \
                cp -R "$theme_dir" "${THEME_ROOT}/"; \
                copied_theme=1; \
            fi; \
        done; \
    else \
        echo "Building single client image: ${CLIENT_ID}"; \
        if [ ! -d "/tmp/clienti/${CLIENT_ID}/themes" ]; then \
            echo "ERROR: themes folder not found: /tmp/clienti/${CLIENT_ID}/themes"; \
            exit 1; \
        fi; \
        for theme_dir in /tmp/clienti/${CLIENT_ID}/themes/*; do \
            if [ -d "$theme_dir" ]; then \
                theme_name="${theme_dir##*/}"; \
                case "$theme_name" in \
                    base|keycloak|keycloak-preview) \
                        echo "ERROR: refusing to copy reserved Keycloak system theme: $theme_name"; \
                        exit 1; \
                        ;; \
                esac; \
                echo "Copying theme: $theme_name"; \
                cp -R "$theme_dir" "${THEME_ROOT}/"; \
                copied_theme=1; \
            fi; \
        done; \
    fi; \
    if [ "$copied_theme" = "0" ]; then \
        echo "ERROR: no theme folders found for CLIENT_ID=${CLIENT_ID}"; \
        exit 1; \
    fi; \
    rm -rf /tmp/clienti; \
    echo "Installed themes:"; \
    ls -la "${THEME_ROOT}"

ENV KC_HTTP_ENABLED=true
ENV KC_HOSTNAME_STRICT=false
ENV KC_SPI_THEME_STATIC_MAX_AGE=-1
ENV KC_SPI_THEME_CACHE_THEMES=false
ENV KC_SPI_THEME_CACHE_TEMPLATES=false

COPY scripts/kc-entrypoint.sh /opt/keycloak/bin/kc-entrypoint.sh
RUN chmod +x /opt/keycloak/bin/kc-entrypoint.sh

# Non mettere KEYCLOAK_ADMIN_PASSWORD nel Dockerfile:
# passalo a runtime con -e oppure tramite secrets della piattaforma.
EXPOSE 8080

ENTRYPOINT ["/opt/keycloak/bin/kc-entrypoint.sh"]
CMD ["start", "--optimized"]