# Stage 0: Argomenti globali
ARG KEYCLOAK_VERSION=26.6.1
ARG CLIENT_ID

# Stage 1: Builder
FROM quay.io/keycloak/keycloak:${KEYCLOAK_VERSION} AS builder
# DEVI ridichiarare l'ARG qui dentro
ARG CLIENT_ID

# Copia dalla root del progetto (context: .)
COPY base/extensions /opt/keycloak/extensions

RUN /opt/keycloak/bin/kc.sh build

# Stage 2: Runtime
FROM quay.io/keycloak/keycloak:${KEYCLOAK_VERSION}
# DEVI ridichiarare l'ARG anche qui
ARG CLIENT_ID

COPY --from=builder /opt/keycloak/lib/quarkus/ /opt/keycloak/lib/quarkus/

# Percorsi relativi alla root del progetto
COPY clienti/${CLIENT_ID}/themes /opt/keycloak/themes
COPY clienti/${CLIENT_ID}/config.env /opt/keycloak/.env

ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]
CMD ["start", "--optimized"]