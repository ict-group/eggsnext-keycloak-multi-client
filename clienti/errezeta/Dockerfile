ARG KEYCLOAK_VERSION=24.0.0
ARG CLIENT_ID

FROM quay.io/keycloak/keycloak:${KEYCLOAK_VERSION} as builder

# Copia extensions comuni (se necessario)
ARG CLIENT_ID
COPY base/extensions /opt/keycloak/extensions

# Build stage
RUN /opt/keycloak/bin/kc.sh build

# Runtime stage
FROM quay.io/keycloak/keycloak:${KEYCLOAK_VERSION}
COPY --from=builder /opt/keycloak/lib/quarkus/ /opt/keycloak/lib/quarkus/

# Copia configurazioni
ARG CLIENT_ID
COPY clienti/${CLIENT_ID}/themes /opt/keycloak/themes
COPY clienti/${CLIENT_ID}/config.env /opt/keycloak/.env

# Variabili d'ambiente per il tema
ENV KC_THEME=errezeta-theme
ENV KC_FEATURES=preview

ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]
CMD ["start", "--optimized"]