# =============================================================================
# KEYCLOAK MULTI-CLIENT DOCKERFILE
# Supporta:
# - Keycloak >= 17 (Quarkus)  → target: runtime-quarkus
# - Keycloak <  17 (WildFly)  → target: runtime-wildfly
# - build singolo cliente: CLIENT_ID=papalini, poma, ict-group, ecc.
# - build globale: CLIENT_ID=all-themes
# Il target viene scelto automaticamente dal workflow in base alla versione.
# =============================================================================

ARG KEYCLOAK_VERSION=26.6.1
ARG CLIENT_ID

# =============================================================================
# STAGE 1a - BUILDER QUARKUS (Keycloak >= 17)
# =============================================================================
FROM quay.io/keycloak/keycloak:${KEYCLOAK_VERSION} AS builder-quarkus
ARG CLIENT_ID
COPY base/extensions /opt/keycloak/providers
RUN /opt/keycloak/bin/kc.sh build

# =============================================================================
# STAGE 1b - BUILDER WILDFLY (Keycloak < 17)
# =============================================================================
FROM jboss/keycloak:${KEYCLOAK_VERSION} AS builder-wildfly
ARG CLIENT_ID
COPY base/extensions /opt/jboss/keycloak/standalone/deployments/

# =============================================================================
# STAGE 2a - RUNTIME QUARKUS (Keycloak >= 17)
# =============================================================================
FROM quay.io/keycloak/keycloak:${KEYCLOAK_VERSION} AS runtime-quarkus
ARG CLIENT_ID

COPY --from=builder-quarkus /opt/keycloak/lib/quarkus/ /opt/keycloak/lib/quarkus/
COPY --chown=keycloak:keycloak clienti /tmp/clienti

RUN mkdir -p /opt/keycloak/themes && \
    if [ "$CLIENT_ID" = "all-themes" ] ; then \
        echo "Building ALL THEMES image (quarkus)" ; \
        for theme_dir in /tmp/clienti/*/themes/* ; do \
            if [ -d "$theme_dir" ] ; then \
                echo "Copying theme: $theme_dir" ; \
                cp -R "$theme_dir" /opt/keycloak/themes/ ; \
            fi ; \
        done ; \
    else \
        echo "Building single client image: $CLIENT_ID (quarkus)" ; \
        if [ -d "/tmp/clienti/${CLIENT_ID}/themes" ] ; then \
            cp -R /tmp/clienti/${CLIENT_ID}/themes/* /opt/keycloak/themes/ ; \
        else \
            echo "ERROR: themes folder not found for CLIENT_ID=${CLIENT_ID}" ; \
            exit 1 ; \
        fi ; \
    fi && \
    rm -rf /tmp/clienti

ENV KC_HTTP_ENABLED=true
ENV KC_HOSTNAME_STRICT=false
ENV KC_SPI_THEME_STATIC_MAX_AGE=-1
ENV KC_SPI_THEME_CACHE_THEMES=false
ENV KC_SPI_THEME_CACHE_TEMPLATES=false

ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]
CMD ["start", "--optimized"]

# =============================================================================
# STAGE 2b - RUNTIME WILDFLY (Keycloak < 17)
# =============================================================================
FROM jboss/keycloak:${KEYCLOAK_VERSION} AS runtime-wildfly
ARG CLIENT_ID

COPY --from=builder-wildfly /opt/jboss/keycloak/standalone/deployments/ /opt/jboss/keycloak/standalone/deployments/
COPY --chown=jboss:jboss clienti /tmp/clienti

RUN mkdir -p /opt/jboss/keycloak/themes && \
    if [ "$CLIENT_ID" = "all-themes" ] ; then \
        echo "Building ALL THEMES image (wildfly)" ; \
        for theme_dir in /tmp/clienti/*/themes/* ; do \
            if [ -d "$theme_dir" ] ; then \
                echo "Copying theme: $theme_dir" ; \
                cp -R "$theme_dir" /opt/jboss/keycloak/themes/ ; \
            fi ; \
        done ; \
    else \
        echo "Building single client image: $CLIENT_ID (wildfly)" ; \
        if [ -d "/tmp/clienti/${CLIENT_ID}/themes" ] ; then \
            cp -R /tmp/clienti/${CLIENT_ID}/themes/* /opt/jboss/keycloak/themes/ ; \
        else \
            echo "ERROR: themes folder not found for CLIENT_ID=${CLIENT_ID}" ; \
            exit 1 ; \
        fi ; \
    fi && \
    rm -rf /tmp/clienti

ENV KEYCLOAK_HTTP_ENABLED=true
ENV KEYCLOAK_HOSTNAME_STRICT=false

ENTRYPOINT ["/opt/jboss/keycloak/bin/standalone.sh"]
CMD ["-b", "0.0.0.0"]