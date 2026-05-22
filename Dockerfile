# =============================================================================
# KEYCLOAK MULTI-CLIENT DOCKERFILE
# Supporta:
# - build singolo cliente: CLIENT_ID=papalini, poma, ict-group, ecc.
# - build globale: CLIENT_ID=all-themes
# =============================================================================

ARG KEYCLOAK_VERSION=26.6.1
ARG CLIENT_ID

# =============================================================================
# STAGE 1 - BUILDER
# =============================================================================
FROM quay.io/keycloak/keycloak:${KEYCLOAK_VERSION} AS builder

ARG CLIENT_ID

# Provider custom
COPY base/extensions /opt/keycloak/providers

RUN /opt/keycloak/bin/kc.sh build


# =============================================================================
# STAGE 2 - RUNTIME
# =============================================================================
FROM quay.io/keycloak/keycloak:${KEYCLOAK_VERSION}

ARG CLIENT_ID

COPY --from=builder /opt/keycloak/lib/quarkus/ /opt/keycloak/lib/quarkus/

# Copio le cartelle clienti assegnando i permessi all'utente keycloak.
# Gli env/config devono essere esclusi dal .dockerignore.
COPY --chown=keycloak:keycloak clienti /tmp/clienti

# =============================================================================
# THEME COPY LOGIC
# =============================================================================
# Se CLIENT_ID=all-themes:
#   copia tutti i temi da clienti/*/themes/*
#
# Altrimenti:
#   copia solo i temi del cliente specifico clienti/${CLIENT_ID}/themes/*
# =============================================================================
RUN mkdir -p /opt/keycloak/themes && \
    if [ "$CLIENT_ID" = "all-themes" ] ; then \
        echo "Building ALL THEMES image" ; \
        for theme_dir in /tmp/clienti/*/themes/* ; do \
            if [ -d "$theme_dir" ] ; then \
                echo "Copying theme: $theme_dir" ; \
                cp -R "$theme_dir" /opt/keycloak/themes/ ; \
            fi ; \
        done ; \
    else \
        echo "Building single client image: $CLIENT_ID" ; \
        if [ -d "/tmp/clienti/${CLIENT_ID}/themes" ] ; then \
            cp -R /tmp/clienti/${CLIENT_ID}/themes/* /opt/keycloak/themes/ ; \
        else \
            echo "ERROR: themes folder not found for CLIENT_ID=${CLIENT_ID}" ; \
            exit 1 ; \
        fi ; \
    fi && \
    rm -rf /tmp/clienti


# =============================================================================
# ADMIN COMPATIBILITY
# =============================================================================

ENV KEYCLOAK_ADMIN=admin
ENV KEYCLOAK_ADMIN_PASSWORD=admin

ENV KC_BOOTSTRAP_ADMIN_USERNAME=admin
ENV KC_BOOTSTRAP_ADMIN_PASSWORD=admin


# =============================================================================
# LOCAL DEV DEFAULTS
# =============================================================================

ENV KC_HTTP_ENABLED=true
ENV KC_HOSTNAME_STRICT=false

ENV KC_SPI_THEME_STATIC_MAX_AGE=-1
ENV KC_SPI_THEME_CACHE_THEMES=false
ENV KC_SPI_THEME_CACHE_TEMPLATES=false

ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]
CMD ["start", "--optimized"]