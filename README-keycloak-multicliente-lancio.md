# Keycloak multi-cliente in locale con Docker Compose

Questo repository permette di avviare in locale un ambiente Keycloak scegliendo da terminale:

- il cliente da testare, tramite `CLIENT_ID`
- la versione Keycloak, tramite `KEYCLOAK_VERSION`
- il database locale dedicato al cliente
- i temi del cliente in live reload
- Mailpit per testare le email senza inviarle davvero

La configurazione attuale usa:

```text
Dockerfile
docker-compose-test.yml
.env
clienti/<CLIENT_ID>/config.env
clienti/<CLIENT_ID>/themes
```

---

## Obiettivo

L'obiettivo è avere un solo repository multi-cliente dove puoi lanciare, per esempio:

```bash
CLIENT_ID=errevi KEYCLOAK_VERSION=24.0.0 KEYCLOAK_DB_NAME=keycloak_errevi docker compose -f docker-compose-test.yml up --build
```

oppure:

```bash
CLIENT_ID=errezeta KEYCLOAK_VERSION=24.0.0 KEYCLOAK_DB_NAME=keycloak_errezeta docker compose -f docker-compose-test.yml up --build
```

In questo modo puoi testare clienti diversi senza duplicare Dockerfile o Compose.

---

## Servizi avviati

Il file `docker-compose-test.yml` avvia tre servizi:

```text
keycloak  → server Keycloak locale
postgres  → database PostgreSQL locale
mailpit   → SMTP fake per test email
```

Indirizzi locali:

```text
Keycloak: http://localhost:8080
Mailpit:  http://localhost:8025
Postgres: localhost:5432
```

Credenziali admin Keycloak di default:

```text
username: admin
password: admin
```

---

## Struttura attesa del repository

La struttura minima attesa è questa:

```text
eggsnext-keycloak-multi-client/
├── Dockerfile
├── docker-compose-test.yml
├── .env
├── base/
│   └── extensions/
│       └── eventuali-provider-custom.jar
└── clienti/
    ├── errevi/
    │   ├── config.env
    │   └── themes/
    │       └── errevi-theme/
    │           ├── login/
    │           ├── email/
    │           └── admin/
    │
    ├── errezeta/
    │   ├── config.env
    │   └── themes/
    │       └── errezeta-theme/
    │           └── login/
    │
    └── altro-cliente/
        ├── config.env
        └── themes/
```

Per ogni cliente deve esistere:

```text
clienti/<CLIENT_ID>/config.env
clienti/<CLIENT_ID>/themes
```

Esempio:

```text
clienti/errevi/config.env
clienti/errevi/themes
```

---

## File `.env`

Docker Compose legge automaticamente il file `.env` presente nella root.

File attuale:

```env
CLIENT_ID=errevi
KEYCLOAK_VERSION=24.0.0

KEYCLOAK_PORT=8080
KEYCLOAK_ADMIN_USER=admin
KEYCLOAK_ADMIN_PASSWORD=admin

KEYCLOAK_DB_NAME=keycloak_errevi
KEYCLOAK_DB_USER=keycloak
KEYCLOAK_DB_PASSWORD=change-me
POSTGRES_PORT=5432

MAILPIT_SMTP_PORT=1025
MAILPIT_WEB_PORT=8025
```

### Significato delle variabili

```env
CLIENT_ID=errevi
```

Indica quale cartella cliente usare:

```text
clienti/errevi
```

```env
KEYCLOAK_VERSION=24.0.0
```

Indica quale immagine Keycloak usare:

```text
quay.io/keycloak/keycloak:24.0.0
```

```env
KEYCLOAK_DB_NAME=keycloak_errevi
```

Indica il nome del database PostgreSQL locale.

Per convenzione è consigliato usare:

```text
keycloak_<CLIENT_ID>
```

Esempi:

```env
CLIENT_ID=errevi
KEYCLOAK_DB_NAME=keycloak_errevi
```

```env
CLIENT_ID=errezeta
KEYCLOAK_DB_NAME=keycloak_errezeta
```

```env
KEYCLOAK_DB_USER=keycloak
KEYCLOAK_DB_PASSWORD=change-me
```

Sono utente e password usati sia da Keycloak sia da PostgreSQL.

Devono essere sempre coerenti tra loro.

---

## Dockerfile attuale

Il Dockerfile è generico: riceve la versione Keycloak tramite `KEYCLOAK_VERSION`, copia eventuali provider custom da `base/extensions` e prepara l'immagine.

```dockerfile
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
```

### Cosa fa

Questa riga usa la versione scelta:

```dockerfile
FROM quay.io/keycloak/keycloak:${KEYCLOAK_VERSION}
```

Questa riga copia eventuali provider custom:

```dockerfile
COPY base/extensions /opt/keycloak/providers
```

Questa riga esegue la build Quarkus di Keycloak:

```dockerfile
RUN /opt/keycloak/bin/kc.sh build
```

Il Dockerfile non decide il cliente. Il cliente viene deciso dal Compose tramite:

```yaml
env_file:
  - ./clienti/${CLIENT_ID}/cps.env

volumes:
  - ./clienti/${CLIENT_ID}/themes:/opt/keycloak/themes
```

---

## Docker Compose attuale

File: `docker-compose-test.yml`

```yaml
services:
  keycloak:
    build:
      context: .
      dockerfile: Dockerfile
      args:
        # Passa correttamente la versione al Dockerfile
        KEYCLOAK_VERSION: ${KEYCLOAK_VERSION:-26.6.1}

    container_name: keycloak-${CLIENT_ID}

    ports:
      - "${KEYCLOAK_PORT:-8080}:8080"

    env_file:
      - ./clienti/${CLIENT_ID}/cps.env

    environment:
      KEYCLOAK_ADMIN: ${KEYCLOAK_ADMIN_USER:-admin}
      KEYCLOAK_ADMIN_PASSWORD: ${KEYCLOAK_ADMIN_PASSWORD:-admin}
      KC_BOOTSTRAP_ADMIN_USERNAME: ${KEYCLOAK_ADMIN_USER:-admin}
      KC_BOOTSTRAP_ADMIN_PASSWORD: ${KEYCLOAK_ADMIN_PASSWORD:-admin}

      KC_HTTP_ENABLED: "true"
      KC_HOSTNAME: localhost
      KC_HOSTNAME_STRICT: "false"
      KC_HOSTNAME_STRICT_HTTPS: "false"
      KC_PROXY: none

      KC_DB: postgres
      # Il database ora si chiama dinamicamente come il cliente (es. keycloak_errezeta)
      KC_DB_URL: jdbc:postgresql://postgres:5432/${KEYCLOAK_DB_NAME:-keycloak_${CLIENT_ID}}
      KC_DB_USERNAME: ${KEYCLOAK_DB_USER:-keycloak}
      KC_DB_PASSWORD: ${KEYCLOAK_DB_PASSWORD:-change-me}

    volumes:
      # Puntamento dinamico alla cartella del tema del cliente X
      - ./clienti/${CLIENT_ID}/themes:/opt/keycloak/themes

    command:
      - start-dev
      - --spi-theme-static-max-age=-1
      - --spi-theme-cache-themes=false
      - --spi-theme-cache-templates=false

    depends_on:
      postgres:
        condition: service_healthy
      mailpit:
        condition: service_started

  postgres:
    image: postgres:16
    container_name: postgres-${CLIENT_ID}

    environment:
      POSTGRES_DB: ${KEYCLOAK_DB_NAME:-keycloak_${CLIENT_ID}}
      POSTGRES_USER: ${KEYCLOAK_DB_USER:-keycloak}
      POSTGRES_PASSWORD: ${KEYCLOAK_DB_PASSWORD:-change-me}

    ports:
      - "${POSTGRES_PORT:-5432}:5432"

    volumes:
      - postgres-data:/var/lib/postgresql/data

    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${KEYCLOAK_DB_USER:-keycloak} -d ${KEYCLOAK_DB_NAME:-keycloak_${CLIENT_ID}}"]
      interval: 5s
      timeout: 5s
      retries: 20

  mailpit:
    image: axllent/mailpit:latest
    container_name: mailpit-${CLIENT_ID}

    ports:
      - "${MAILPIT_SMTP_PORT:-1025}:1025"
      - "${MAILPIT_WEB_PORT:-8025}:8025"

volumes:
  postgres-data:
    # Isola i dati del database per ciascun cliente!
    name: keycloak-postgres-${CLIENT_ID}
```

---

## Come funziona la scelta del cliente

Il cliente è scelto tramite:

```env
CLIENT_ID=errevi
```

Il Compose usa questa variabile in tre punti importanti.

### 1. Legge il config del cliente

```yaml
env_file:
  - ./clienti/${CLIENT_ID}/cps.env
```

Quindi se `CLIENT_ID=errevi`, legge:

```text
clienti/errevi/config.env
```

Se `CLIENT_ID=errezeta`, legge:

```text
clienti/errezeta/config.env
```

---

### 2. Monta i temi del cliente

```yaml
volumes:
  - ./clienti/${CLIENT_ID}/themes:/opt/keycloak/themes
```

Quindi se modifichi un file in:

```text
clienti/errevi/themes/errevi-theme/login/resources/css/style.css
```

Keycloak lo vede dentro il container in:

```text
/opt/keycloak/themes
```

Questo permette il live reload dei temi senza ricostruire l'immagine Docker.

---

### 3. Crea container e volume dedicati al cliente

Esempio con `CLIENT_ID=errevi`:

```text
keycloak-errevi
postgres-errevi
mailpit-errevi
keycloak-postgres-errevi
```

Esempio con `CLIENT_ID=errezeta`:

```text
keycloak-errezeta
postgres-errezeta
mailpit-errezeta
keycloak-postgres-errezeta
```

Il volume PostgreSQL è isolato per cliente:

```yaml
volumes:
  postgres-data:
    name: keycloak-postgres-${CLIENT_ID}
```

Questo evita di mischiare i database tra clienti diversi.

---

## Come funziona la scelta della versione Keycloak

La versione viene scelta tramite:

```env
KEYCLOAK_VERSION=24.0.0
```

oppure da terminale:

```bash
KEYCLOAK_VERSION=26.6.1 docker compose -f docker-compose-test.yml up --build
```

Il Compose passa questa variabile al Dockerfile:

```yaml
build:
  args:
    KEYCLOAK_VERSION: ${KEYCLOAK_VERSION:-26.6.1}
```

Il Dockerfile poi la usa qui:

```dockerfile
FROM quay.io/keycloak/keycloak:${KEYCLOAK_VERSION}
```

---

## Avvio standard usando `.env`

Dalla root del repository:

```bash
docker compose -f docker-compose-test.yml up --build
```

Con il file `.env` attuale questo avvia:

```text
CLIENT_ID=errevi
KEYCLOAK_VERSION=24.0.0
KEYCLOAK_DB_NAME=keycloak_errevi
```

---

## Avvio in background

```bash
docker compose -f docker-compose-test.yml up --build -d
```

Log:

```bash
docker compose -f docker-compose-test.yml logs -f keycloak
```

---

## Avvio di un cliente specifico da terminale

### Errevi

```bash
CLIENT_ID=errevi \
KEYCLOAK_VERSION=24.0.0 \
KEYCLOAK_DB_NAME=keycloak_errevi \
KEYCLOAK_DB_USER=keycloak \
KEYCLOAK_DB_PASSWORD=change-me \
docker compose -f docker-compose-test.yml up --build
```

### Errezeta

```bash
CLIENT_ID=errezeta \
KEYCLOAK_VERSION=24.0.0 \
KEYCLOAK_DB_NAME=keycloak_errezeta \
KEYCLOAK_DB_USER=keycloak \
KEYCLOAK_DB_PASSWORD=change-me \
docker compose -f docker-compose-test.yml up --build
```

### Altro cliente

```bash
CLIENT_ID=nomecliente \
KEYCLOAK_VERSION=24.0.0 \
KEYCLOAK_DB_NAME=keycloak_nomecliente \
KEYCLOAK_DB_USER=keycloak \
KEYCLOAK_DB_PASSWORD=change-me \
docker compose -f docker-compose-test.yml up --build
```

---

## Nota importante su `KEYCLOAK_DB_NAME`

Nel Compose c'è questo default:

```yaml
KEYCLOAK_DB_NAME:-keycloak_${CLIENT_ID}
```

Per evitare ambiguità, soprattutto quando nel file `.env` è già presente `KEYCLOAK_DB_NAME=keycloak_errevi`, è meglio passare sempre esplicitamente anche `KEYCLOAK_DB_NAME` quando lanci un cliente diverso da quello nel `.env`.

Esempio corretto:

```bash
CLIENT_ID=errezeta KEYCLOAK_DB_NAME=keycloak_errezeta docker compose -f docker-compose-test.yml up --build
```

Esempio da evitare:

```bash
CLIENT_ID=errezeta docker compose -f docker-compose-test.yml up --build
```

Se nel `.env` è ancora presente:

```env
KEYCLOAK_DB_NAME=keycloak_errevi
```

allora rischi di avviare il cliente `errezeta` usando il database `keycloak_errevi`.

---

## Primo avvio pulito

Quando cambi cliente, versione Keycloak o password DB, conviene pulire il volume del cliente.

Per il cliente attuale indicato nel `.env`:

```bash
docker compose -f docker-compose-test.yml down -v --remove-orphans
docker compose -f docker-compose-test.yml up --build
```

Per un cliente specifico da terminale:

```bash
CLIENT_ID=errevi docker compose -f docker-compose-test.yml down -v --remove-orphans
CLIENT_ID=errevi KEYCLOAK_DB_NAME=keycloak_errevi docker compose -f docker-compose-test.yml up --build
```

Per Errezeta:

```bash
CLIENT_ID=errezeta docker compose -f docker-compose-test.yml down -v --remove-orphans
CLIENT_ID=errezeta KEYCLOAK_DB_NAME=keycloak_errezeta docker compose -f docker-compose-test.yml up --build
```

---

## Purga completa di un cliente

Esempio per Errevi:

```bash
CLIENT_ID=errevi docker compose -f docker-compose-test.yml down -v --remove-orphans
docker rm -f keycloak-errevi postgres-errevi mailpit-errevi 2>/dev/null || true
docker volume rm keycloak-postgres-errevi 2>/dev/null || true
docker builder prune -f
```

Poi riparti:

```bash
CLIENT_ID=errevi \
KEYCLOAK_VERSION=24.0.0 \
KEYCLOAK_DB_NAME=keycloak_errevi \
KEYCLOAK_DB_PASSWORD=change-me \
docker compose -f docker-compose-test.yml up --build
```

---

## Live reload dei temi

Il live reload dei temi è gestito dal volume:

```yaml
- ./clienti/${CLIENT_ID}/themes:/opt/keycloak/themes
```

Quindi puoi modificare direttamente:

```text
clienti/<CLIENT_ID>/themes/<nome-tema>/login/resources/css/style.css
clienti/<CLIENT_ID>/themes/<nome-tema>/login/resources/css/otp.css
clienti/<CLIENT_ID>/themes/<nome-tema>/login/login.ftl
clienti/<CLIENT_ID>/themes/<nome-tema>/email/html/password-reset.ftl
clienti/<CLIENT_ID>/themes/<nome-tema>/email/messages/messages_it.properties
```

Dopo una modifica CSS di solito basta:

```text
CTRL + F5
```

Se non cambia nulla:

```bash
docker compose -f docker-compose-test.yml exec keycloak rm -rf /opt/keycloak/data/tmp/kc-gzip-cache
docker compose -f docker-compose-test.yml restart keycloak
```

---

## Cache temi disabilitata

Nel Compose Keycloak parte con:

```yaml
command:
  - start-dev
  - --spi-theme-static-max-age=-1
  - --spi-theme-cache-themes=false
  - --spi-theme-cache-templates=false
```

Significato:

```text
--spi-theme-static-max-age=-1
```

Disabilita la cache delle risorse statiche dei temi.

```text
--spi-theme-cache-themes=false
```

Disabilita la cache dei temi.

```text
--spi-theme-cache-templates=false
```

Disabilita la cache dei template FreeMarker `.ftl`.

---

## Configurazione SMTP Mailpit in Keycloak

Dentro la Admin Console vai in:

```text
Realm settings → Email
```

Imposta:

```text
Host: mailpit
Port: 1025
From: noreply@errevi.local
From display name: Errevi Automation
Reply to: noreply@errevi.local
Reply to display name: Errevi Automation
Envelope from: noreply@errevi.local
```

Sicurezza/autenticazione:

```text
Enable SSL: OFF
Enable StartTLS: OFF
Enable authentication: OFF
```

oppure, se la UI mostra campi diversi:

```text
Authentication: OFF
Encryption: NONE
```

Poi clicca:

```text
Test connection
```

Le email appaiono qui:

```text
http://localhost:8025
```

Usare `mailpit`, non `localhost`, perché Keycloak gira dentro Docker e raggiunge Mailpit tramite il nome del servizio Compose.

---

## Impostazione temi in Keycloak

Dopo l'avvio:

```text
http://localhost:8080
```

Login:

```text
admin / admin
```

Vai in:

```text
Realm settings → Themes
```

Imposta, per esempio:

```text
Login theme: errevi-theme
Email theme: errevi-theme
Admin theme: keycloak.v3
```

Nota: è meglio lasciare `Admin theme` su `keycloak.v3`, a meno che il tema admin custom sia davvero completo. Un admin theme incompleto può bloccare la console su schermata bianca o rotellina infinita.

---

## Test email reset password

1. Vai in:

```text
Realm settings → Email
```

2. Configura Mailpit e fai `Test connection`.

3. Crea o scegli un utente:

```text
Users → Add user
```

Esempio:

```text
Username: test-reset
Email: test@errevi.local
Email verified: ON
Enabled: ON
```

4. Invia l'azione:

```text
Users → test-reset → Required actions / Execute actions email
```

Seleziona:

```text
UPDATE_PASSWORD
```

5. Apri Mailpit:

```text
http://localhost:8025
```

---

## Comandi utili

### Avvio

```bash
docker compose -f docker-compose-test.yml up --build
```

### Avvio background

```bash
docker compose -f docker-compose-test.yml up --build -d
```

### Stop

```bash
docker compose -f docker-compose-test.yml down
```

### Stop con cancellazione volume DB

```bash
docker compose -f docker-compose-test.yml down -v --remove-orphans
```

### Log Keycloak

```bash
docker compose -f docker-compose-test.yml logs -f keycloak
```

### Log Postgres

```bash
docker compose -f docker-compose-test.yml logs -f postgres
```

### Log Mailpit

```bash
docker compose -f docker-compose-test.yml logs -f mailpit
```

### Entrare nel container Keycloak

```bash
docker compose -f docker-compose-test.yml exec keycloak bash
```

### Verificare temi montati

```bash
docker compose -f docker-compose-test.yml exec keycloak ls -la /opt/keycloak/themes
```

### Verificare database PostgreSQL

```bash
docker compose -f docker-compose-test.yml exec postgres psql -U keycloak -d postgres -c "\l"
```

### Verificare connessione al database cliente

```bash
docker compose -f docker-compose-test.yml exec postgres psql -U keycloak -d keycloak_errevi -c "select current_database(), current_user;"
```

Per un altro cliente cambia il nome DB:

```bash
docker compose -f docker-compose-test.yml exec postgres psql -U keycloak -d keycloak_errezeta -c "select current_database(), current_user;"
```

---

## Problemi comuni

### `FATAL: database "keycloak_x" does not exist`

Il database richiesto da Keycloak non è stato creato.

Controlla:

```env
KEYCLOAK_DB_NAME=keycloak_errevi
```

e:

```yaml
POSTGRES_DB: ${KEYCLOAK_DB_NAME:-keycloak_${CLIENT_ID}}
```

Poi pulisci il volume:

```bash
CLIENT_ID=errevi docker compose -f docker-compose-test.yml down -v --remove-orphans
CLIENT_ID=errevi KEYCLOAK_DB_NAME=keycloak_errevi docker compose -f docker-compose-test.yml up --build
```

---

### `FATAL: password authentication failed for user "keycloak"`

La password usata da Keycloak non coincide con quella con cui PostgreSQL ha inizializzato l'utente.

Controlla:

```env
KEYCLOAK_DB_PASSWORD=change-me
```

Poi ricrea il volume:

```bash
docker compose -f docker-compose-test.yml down -v --remove-orphans
docker compose -f docker-compose-test.yml up --build
```

---

### `Invalid value for option 'kc.proxy'`

Non usare un valore vuoto per `KC_PROXY`.

Valori validi:

```text
none
edge
reencrypt
passthrough
```

In locale il Compose sovrascrive il config cliente con:

```yaml
KC_PROXY: none
```

---

### Il tema non compare in Keycloak

Controlla che esista:

```text
clienti/<CLIENT_ID>/themes/<nome-tema>/login/theme.properties
```

e, per le email:

```text
clienti/<CLIENT_ID>/themes/<nome-tema>/email/theme.properties
```

Poi:

```bash
docker compose -f docker-compose-test.yml restart keycloak
```

---

### CSS modificato ma non visibile

Esegui:

```bash
docker compose -f docker-compose-test.yml exec keycloak rm -rf /opt/keycloak/data/tmp/kc-gzip-cache
docker compose -f docker-compose-test.yml restart keycloak
```

Poi nel browser:

```text
CTRL + F5
```

---

### Porta 5432 già occupata

Modifica nel `.env`:

```env
POSTGRES_PORT=5433
```

PostgreSQL continuerà a usare `5432` internamente nel network Docker, ma dal PC sarà esposto su `localhost:5433`.

---

### Porta 8080 già occupata

Modifica nel `.env`:

```env
KEYCLOAK_PORT=8081
```

Poi apri:

```text
http://localhost:8081
```

---

## Workflow consigliato

1. Scegli cliente e versione:

```env
CLIENT_ID=errevi
KEYCLOAK_VERSION=24.0.0
KEYCLOAK_DB_NAME=keycloak_errevi
```

2. Avvia:

```bash
docker compose -f docker-compose-test.yml up --build
```

3. Apri Keycloak:

```text
http://localhost:8080
```

4. Login:

```text
admin / admin
```

5. Imposta temi:

```text
Realm settings → Themes
```

6. Configura SMTP Mailpit:

```text
Realm settings → Email
```

7. Modifica i file tema in:

```text
clienti/<CLIENT_ID>/themes
```

8. Fai refresh browser.

9. Testa email su:

```text
http://localhost:8025
```

---

## Esempi rapidi

### Lancia Errevi con Keycloak 24

```bash
CLIENT_ID=errevi \
KEYCLOAK_VERSION=24.0.0 \
KEYCLOAK_DB_NAME=keycloak_errevi \
KEYCLOAK_DB_PASSWORD=change-me \
docker compose -f docker-compose-test.yml up --build
```

### Lancia Errevi con Keycloak 26

```bash
CLIENT_ID=errevi \
KEYCLOAK_VERSION=26.6.1 \
KEYCLOAK_DB_NAME=keycloak_errevi \
KEYCLOAK_DB_PASSWORD=change-me \
docker compose -f docker-compose-test.yml up --build
```

### Lancia Errezeta con Keycloak 24

```bash
CLIENT_ID=errezeta \
KEYCLOAK_VERSION=24.0.0 \
KEYCLOAK_DB_NAME=keycloak_errezeta \
KEYCLOAK_DB_PASSWORD=change-me \
docker compose -f docker-compose-test.yml up --build
```

---

## Riepilogo

Per lanciare un cliente X con versione Y:

```bash
CLIENT_ID=<cliente> \
KEYCLOAK_VERSION=<versione> \
KEYCLOAK_DB_NAME=keycloak_<cliente> \
KEYCLOAK_DB_PASSWORD=change-me \
docker compose -f docker-compose-test.yml up --build
```

Esempio:

```bash
CLIENT_ID=errevi \
KEYCLOAK_VERSION=24.0.0 \
KEYCLOAK_DB_NAME=keycloak_errevi \
KEYCLOAK_DB_PASSWORD=change-me \
docker compose -f docker-compose-test.yml up --build
```

Per ripartire pulito:

```bash
CLIENT_ID=<cliente> docker compose -f docker-compose-test.yml down -v --remove-orphans
```

Poi rilancia con le variabili corrette.
