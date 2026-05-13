ARG KEYCLOAK_VERSION=24.0.0
FROM quay.io/keycloak/keycloak:${KEYCLOAK_VERSION} as builder

# Copia extensions comuni (se necessario)
COPY base/extensions /opt/keycloak/extensions

# Build stage
RUN /opt/keycloak/bin/kc.sh build

# Runtime stage
FROM quay.io/keycloak/keycloak:${KEYCLOAK_VERSION}
COPY --from=builder /opt/keycloak/lib/quarkus/ /opt/keycloak/lib/quarkus/

# Copia configurazioni
COPY clienti/errezeta/config.env /opt/keycloak/.env
COPY clienti/errezeta/themes /opt/keycloak/themes

# Variabili d'ambiente per il tema
ENV KC_THEME=errezeta-theme
ENV KC_FEATURES=preview

ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]
CMD ["start", "--optimized"]