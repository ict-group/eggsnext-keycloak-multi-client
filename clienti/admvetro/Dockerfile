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

# --- VARIABILI DI COMPATIBILITÀ UNIVERSALE ---

# Vecchio set (per Keycloak v24 e precedenti)
ENV KEYCLOAK_ADMIN=admin
ENV KEYCLOAK_ADMIN_PASSWORD=admin

# Nuovo set (per Keycloak v26+)
ENV KC_BOOTSTRAP_ADMIN_USERNAME=admin
ENV KC_BOOTSTRAP_ADMIN_PASSWORD=admin

# Impostazioni di rete comuni
ENV KC_HTTP_ENABLED=true
ENV KC_HOSTNAME_STRICT=false
ENV KC_HOSTNAME_STRICT_HTTPS=false

# Sviluppo Temi (valido per quasi tutte le versioni recenti)
ENV KC_THEME_CACHE_THEMES=false
ENV KC_THEME_CACHE_TEMPLATES=false

# Variabili per lo sviluppo (disabilitano la cache dei temi)
ENV KC_THEME_CACHE_THEMES=false
ENV KC_THEME_CACHE_TEMPLATES=false

ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]
CMD ["start", "--optimized"]