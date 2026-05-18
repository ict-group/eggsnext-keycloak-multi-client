# Stage 0: Argomenti globali
ARG KEYCLOAK_VERSION=26.6.1

# Stage 1: Builder
FROM quay.io/keycloak/keycloak:${KEYCLOAK_VERSION} AS builder

ARG KEYCLOAK_VERSION

COPY base/extensions /opt/keycloak/providers

RUN /opt/keycloak/bin/kc.sh build

# Stage 2: Runtime
FROM quay.io/keycloak/keycloak:${KEYCLOAK_VERSION}

ARG KEYCLOAK_VERSION

COPY --from=builder /opt/keycloak/ /opt/keycloak/

ENV KC_BOOTSTRAP_ADMIN_USERNAME=admin
ENV KC_BOOTSTRAP_ADMIN_PASSWORD=admin

ENV KEYCLOAK_ADMIN=admin
ENV KEYCLOAK_ADMIN_PASSWORD=admin

ENV KC_HTTP_ENABLED=true
ENV KC_HOSTNAME_STRICT=false
ENV KC_HOSTNAME_STRICT_HTTPS=false

ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]