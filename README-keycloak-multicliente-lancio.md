# Keycloak multi-cliente in locale con Docker Compose

Questo repository permette di avviare in locale un ambiente Keycloak scegliendo da terminale:

- il cliente da testare, tramite `CLIENT_ID`
- la versione Keycloak, tramite `KEYCLOAK_VERSION`
- il database locale dedicato al cliente
- i temi del cliente in live reload
- Mailpit per testare le email senza inviarle davvero

La configurazione attuale usa:

```text
Dockerfile              ← versioni >= 17 (Quarkus)
Dockerfile.legacy       ← versioni <  17 (WildFly/JBoss)
docker-compose-test.yml
test-image.sh           ← script di lancio che sceglie il Dockerfile giusto
.env
clienti/<CLIENT_ID>/<CLIENT_ID>.env
clienti/<CLIENT_ID>/themes
```

---

## ⚠️ Versioni Keycloak: due architetture diverse

Questa è la cosa più importante da sapere prima di lavorare con questo repository.

Keycloak ha cambiato architettura completamente alla versione 17:

| Versione | Architettura | Immagine base | Path interno |
|---|---|---|---|
| <= 16 | WildFly / JBoss | `quay.io/keycloak/keycloak` | `/opt/jboss/keycloak` |
| >= 17 | Quarkus | `quay.io/keycloak/keycloak` | `/opt/keycloak` |

Questo significa che:

- il Dockerfile è **diverso** (`Dockerfile` vs `Dockerfile.legacy`)
- il comando di avvio è **diverso** (`start-dev` vs `-b 0.0.0.0`)
- le variabili d'ambiente sono **diverse** (vedi tabella sotto)
- il CSS dei temi usa **classi diverse** (PatternFly 4 vs PatternFly 3)
- la console admin si raggiunge su path **diversi**

Lo script `test-image.sh` gestisce tutto questo automaticamente in base alla major version.

---

### Variabili d'ambiente per versione

| Variabile | Keycloak >= 17 (Quarkus) | Keycloak <= 16 (WildFly) |
|---|---|---|
| Utente admin | `KEYCLOAK_ADMIN` + `KC_BOOTSTRAP_ADMIN_USERNAME` | `KEYCLOAK_USER` |
| Password admin | `KEYCLOAK_ADMIN_PASSWORD` + `KC_BOOTSTRAP_ADMIN_PASSWORD` | `KEYCLOAK_PASSWORD` |
| DB vendor | `KC_DB=postgres` | `DB_VENDOR=postgres` |
| DB host | `KC_DB_URL=jdbc:postgresql://...` | `DB_ADDR=postgres` |
| DB nome | (dentro KC_DB_URL) | `DB_DATABASE=...` |
| DB utente | `KC_DB_USERNAME` | `DB_USER` |
| DB password | `KC_DB_PASSWORD` | `DB_PASSWORD` |
| HTTP abilitato | `KC_HTTP_ENABLED=true` | non serve |
| Heap JVM | non serve (gestito da Quarkus) | `JAVA_OPTS=-Xmx1024m ...` |

Il `docker-compose-test.yml` include **entrambi i set** di variabili, quindi funziona per qualsiasi versione senza modifiche.

---

### URL di accesso per versione

| Versione | URL Keycloak | URL Admin Console |
|---|---|---|
| >= 17 (Quarkus) | `http://localhost:8080` | `http://localhost:8080/admin` |
| <= 16 (WildFly) | `http://localhost:8080/auth` | `http://localhost:8080/auth/admin` |

Nota: in Keycloak <= 16 il path `/auth` è sempre presente. In >= 17 non esiste più.

---

### CSS dei temi per versione

Il framework CSS usato da Keycloak è cambiato tra le due architetture:

| Elemento | Keycloak <= 16 (PatternFly 3) | Keycloak >= 17 (PatternFly 4) |
|---|---|---|
| Bottone submit | `.btn.btn-primary` | `.pf-c-button.pf-m-primary` |
| Label form | `.control-label` | `.pf-c-form__label` |
| Wrapper password | `.input-group` | `.pf-c-input-group` |
| Bottone occhio | `.input-group-btn .btn` | `.pf-c-button.pf-m-control` |
| Alert errore | `.alert.alert-danger` | `.kc-feedback-text` (fixed) |
| Social login | `.zocial` | `.pf-c-button.kc-social-item` |

Il file `style.css` incluso in questo repository copre **entrambe le versioni** con selettori doppi. Non è necessario mantenere due CSS separati.

---

### `theme.properties` per versione

In Keycloak <= 16 (WildFly) il `parent` del tema deve essere `keycloak`, non `base`:

```properties
# ✅ Corretto per <= 16
parent=keycloak

# ❌ Non esiste in <= 16, causa NullPointerException
parent=base
```

In Keycloak >= 17 (Quarkus) entrambi funzionano, ma `base` è quello standard:

```properties
# ✅ Corretto per >= 17
parent=base
```

Il `Dockerfile.legacy` corregge automaticamente `parent=base` → `parent=keycloak` durante la build, quindi non devi toccare i file sorgente.

---

### Utente admin per versione

In Keycloak >= 17 l'utente admin viene creato automaticamente all'avvio tramite le variabili d'ambiente se il DB è vuoto.

In Keycloak <= 16 (WildFly) le variabili vengono lette solo al primissimo avvio con DB vuoto. Il `Dockerfile.legacy` crea l'utente admin durante la build tramite `add-user-keycloak.sh`, quindi funziona sempre senza bisogno di ricreate il DB.

---

## Struttura del repository

```text
eggsnext-keycloak-multi-client/
├── Dockerfile                   ← build per Keycloak >= 17 (Quarkus)
├── Dockerfile.legacy            ← build per Keycloak <= 16 (WildFly)
├── docker-compose-test.yml      ← compose unificato per tutte le versioni
├── test-image.sh                ← script che sceglie Dockerfile e parametri giusti
├── .env
├── base/
│   └── extensions/
│       └── eventuali-provider-custom.jar
└── clienti/
    ├── errevi/
    │   ├── errevi.env
    │   └── themes/
    │       └── errevi-theme/
    │           ├── login/
    │           │   ├── theme.properties
    │           │   └── resources/css/style.css
    │           ├── email/
    │           │   └── theme.properties
    │           └── admin/        ← opzionale, lasciare vuoto usa il default
    │
    ├── cps/
    │   ├── cps.env
    │   └── themes/
    │       └── cps-theme/
    │           ├── login/
    │           └── email/
    │
    └── altro-cliente/
        ├── altro-cliente.env
        └── themes/
```

Per ogni cliente deve esistere:

```text
clienti/<CLIENT_ID>/<CLIENT_ID>.env
clienti/<CLIENT_ID>/themes/<nome-tema>/login/theme.properties
```

---

## Come lanciare: script test-image.sh

Lo script `test-image.sh` è il modo corretto per avviare qualsiasi versione. Gestisce automaticamente:

- scelta del Dockerfile (`Dockerfile` o `Dockerfile.legacy`)
- path dei temi nel container
- comando di avvio (`start-dev` o `-b 0.0.0.0`)
- variabili d'ambiente JVM per WildFly

### Utilizzo

```bash
./test-image.sh <CLIENT_ID> [KEYCLOAK_VERSION]
```

### Esempi

```bash
# Versione moderna (>= 17, Quarkus)
./test-image.sh cps 26.6.1

# Versione legacy (<= 16, WildFly)
./test-image.sh cps 11.0.0

# Versione di default (26.6.1)
./test-image.sh cps
```

Lo script scarica automaticamente l'immagine da GHCR prima di avviare.

---

## Come funziona la scelta automatica del Dockerfile

Lo script calcola la major version e sceglie:

```bash
MAJOR=$(echo "$KEYCLOAK_VERSION" | cut -d. -f1)

if [ "$MAJOR" -ge 17 ]; then
  # Dockerfile moderno, Quarkus
  KEYCLOAK_DOCKERFILE=Dockerfile
  KEYCLOAK_THEMES_PATH=/opt/keycloak/themes
  KEYCLOAK_CMD="start-dev ..."
else
  # Dockerfile legacy, WildFly
  KEYCLOAK_DOCKERFILE=Dockerfile.legacy
  KEYCLOAK_THEMES_PATH=/opt/jboss/keycloak/themes
  KEYCLOAK_CMD="-b 0.0.0.0"
fi
```

La stessa logica è nel workflow GitHub Actions (`build-image.yml`) che sceglie automaticamente il Dockerfile corretto al momento della build dell'immagine.

---

## Obiettivo

L'obiettivo è avere un solo repository multi-cliente dove puoi lanciare, per esempio:

```bash
./test-image.sh errevi 24.0.0
```

oppure:

```bash
./test-image.sh errezeta 11.0.0
```

In questo modo puoi testare clienti e versioni diverse senza duplicare Dockerfile o Compose.

---

## Servizi avviati

Il file `docker-compose-test.yml` avvia tre servizi:

```text
keycloak  → server Keycloak locale
postgres  → database PostgreSQL locale
mailpit   → SMTP fake per test email
```

Indirizzi locali (versioni >= 17):

```text
Keycloak:       http://localhost:8080
Admin Console:  http://localhost:8080/admin
Mailpit:        http://localhost:8025
Postgres:       localhost:5432
```

Indirizzi locali (versioni <= 16):

```text
Keycloak:       http://localhost:8080/auth
Admin Console:  http://localhost:8080/auth/admin
Mailpit:        http://localhost:8025
Postgres:       localhost:5432
```

Credenziali admin Keycloak di default:

```text
username: admin
password: Expert0.
```

---

## File `.env`

Docker Compose legge automaticamente il file `.env` presente nella root.

File attuale:

```env
CLIENT_ID=errevi
KEYCLOAK_VERSION=26.6.1

KEYCLOAK_PORT=8080
KEYCLOAK_ADMIN_USER=admin
KEYCLOAK_ADMIN_PASSWORD=Expert0.

KEYCLOAK_DB_NAME=keycloak_errevi
KEYCLOAK_DB_USER=keycloak
KEYCLOAK_DB_PASSWORD=change-me
POSTGRES_PORT=5432

MAILPIT_SMTP_PORT=1025
MAILPIT_WEB_PORT=8025
```

---

## Impostazione temi in Keycloak

Dopo l'avvio, vai in:

```text
Realm settings → Themes
```

Imposta, per esempio:

```text
Login theme:   cps-theme
Email theme:   cps-theme
Admin theme:   keycloak        ← per <= 16 WildFly
Admin theme:   keycloak.v2     ← per >= 17 Quarkus
```

**Importante:** lascia sempre il tema Admin su quello built-in (`keycloak` o `keycloak.v2`). Un tema admin custom incompleto causa schermata bianca o rotellina infinita nella console. La cartella `admin/` nel tema personalizzato è opzionale — se non esiste Keycloak usa il default automaticamente.

---

## Pulizia e ripartenza da zero

Se Keycloak non si avvia correttamente o i dati sono corrotti, cancella il volume DB e riparte:

```bash
docker compose -f docker-compose-test.yml down -v --remove-orphans
./test-image.sh <CLIENT_ID> <VERSIONE>
```

Il flag `-v` cancella il volume PostgreSQL. Al prossimo avvio Keycloak ricrea il DB e l'utente admin da zero.

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
From: noreply@cliente.local
Enable SSL: OFF
Enable StartTLS: OFF
Enable authentication: OFF
```

Le email appaiono su:

```text
http://localhost:8025
```

Usare `mailpit` (non `localhost`) perché Keycloak gira dentro Docker e raggiunge Mailpit tramite il nome del servizio Compose.

---

## Comandi utili

### Avvio tramite script (consigliato)

```bash
./test-image.sh cps 26.6.1
./test-image.sh cps 11.0.0
```

### Avvio manuale

```bash
docker compose -f docker-compose-test.yml up --build
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

### Entrare nel container Keycloak

```bash
# >= 17
docker compose -f docker-compose-test.yml exec keycloak bash

# <= 16
docker exec -it keycloak-<CLIENT_ID>-<VERSION> bash
```

### Verificare temi montati (>= 17)

```bash
docker compose -f docker-compose-test.yml exec keycloak ls -la /opt/keycloak/themes
```

### Verificare temi montati (<= 16)

```bash
docker exec keycloak-<CLIENT_ID>-<VERSION> ls -la /opt/jboss/keycloak/themes
```

### Verificare database PostgreSQL

```bash
docker compose -f docker-compose-test.yml exec postgres psql -U keycloak -d postgres -c "\l"
```

---

## Problemi comuni

### Console admin: rotellina infinita o schermata bianca

Causa più comune: il tema admin del realm è impostato su un tema custom che non ha la cartella `admin/` oppure che usa `parent=base` (non valido in <= 16).

Soluzione:

1. Entra nel container e resetta il tema admin via CLI:

```bash
# >= 17
docker exec -it keycloak-<CLIENT_ID>-<VERSION> /opt/keycloak/bin/kcadm.sh \
  config credentials --server http://localhost:8080 --realm master --user admin --password Expert0.
docker exec -it keycloak-<CLIENT_ID>-<VERSION> /opt/keycloak/bin/kcadm.sh \
  update realms/master -s adminTheme=""

# <= 16
docker exec -it keycloak-<CLIENT_ID>-<VERSION> /opt/jboss/keycloak/bin/kcadm.sh \
  config credentials --server http://localhost:8080/auth --realm master --user admin --password Expert0.
docker exec -it keycloak-<CLIENT_ID>-<VERSION> /opt/jboss/keycloak/bin/kcadm.sh \
  update realms/master -s adminTheme=keycloak
```

2. Oppure cancella il volume e riparte da zero (più semplice):

```bash
docker compose -f docker-compose-test.yml down -v
./test-image.sh <CLIENT_ID> <VERSIONE>
```

---

### `NullPointerException` su `DefaultThemeManager.loadTheme`

Causa: il tema usa `parent=base` ma la versione è <= 16 (WildFly), dove quel parent non esiste.

Soluzione: il `Dockerfile.legacy` corregge automaticamente questo durante la build. Se vedi ancora l'errore, l'immagine è vecchia — fai una nuova build dal workflow GitHub Actions.

---

### `OutOfMemoryError: Java heap space` (solo <= 16)

Causa: WildFly parte con 512MB di heap di default, insufficiente con temi complessi.

Soluzione: il `docker-compose-test.yml` imposta già `JAVA_OPTS` con `-Xmx1024m`. Se il problema persiste aumenta il valore.

---

### `You need local access to create the initial admin user` (solo <= 16)

Causa: il DB esisteva già da avvii precedenti, le variabili `KEYCLOAK_USER/PASSWORD` vengono ignorate.

Soluzione: il `Dockerfile.legacy` crea l'admin durante la build con `add-user-keycloak.sh`. Cancella il volume e riparte:

```bash
docker compose -f docker-compose-test.yml down -v
./test-image.sh <CLIENT_ID> <VERSIONE>
```

---

### `FATAL: database "keycloak_x" does not exist`

Il database richiesto non è stato creato. Pulisci il volume e riparte:

```bash
docker compose -f docker-compose-test.yml down -v --remove-orphans
./test-image.sh <CLIENT_ID> <VERSIONE>
```

---

### `FATAL: password authentication failed for user "keycloak"`

La password usata da Keycloak non coincide con quella con cui PostgreSQL ha inizializzato l'utente. Cancella il volume:

```bash
docker compose -f docker-compose-test.yml down -v --remove-orphans
./test-image.sh <CLIENT_ID> <VERSIONE>
```

---

### Il tema non compare in Keycloak

Controlla che esista:

```text
clienti/<CLIENT_ID>/themes/<nome-tema>/login/theme.properties
```

Poi:

```bash
docker compose -f docker-compose-test.yml restart keycloak
```

---

### CSS modificato ma non visibile

```bash
# >= 17
docker compose -f docker-compose-test.yml exec keycloak rm -rf /opt/keycloak/data/tmp/kc-gzip-cache
docker compose -f docker-compose-test.yml restart keycloak

# <= 16: basta riavviare
docker compose -f docker-compose-test.yml restart keycloak
```

Poi nel browser: `CTRL + F5`

---

### Porta 5432 o 8080 già occupata

Modifica nel `.env`:

```env
POSTGRES_PORT=5433
KEYCLOAK_PORT=8081
```

---

## Workflow consigliato per un nuovo cliente

1. Crea la cartella cliente:

```text
clienti/<CLIENT_ID>/
├── <CLIENT_ID>.env
└── themes/
    └── <CLIENT_ID>-theme/
        ├── login/
        │   ├── theme.properties      ← parent=base (>= 17) o keycloak (<= 16)
        │   └── resources/css/
        │       └── style.css         ← usa il CSS unificato del repository
        └── email/
            └── theme.properties
```

2. Lancia:

```bash
./test-image.sh <CLIENT_ID> <VERSIONE>
```

3. Accedi alla console admin (URL dipende dalla versione, vedi sopra).

4. Vai in `Realm settings → Themes` e imposta i temi.

5. Modifica il CSS e fai refresh browser.

6. Testa le email su `http://localhost:8025`.

---

## Riepilogo rapido versioni

```text
Versione >= 17  →  Dockerfile          →  /opt/keycloak         →  http://localhost:8080/admin
Versione <= 16  →  Dockerfile.legacy   →  /opt/jboss/keycloak   →  http://localhost:8080/auth/admin
```

Lo script `test-image.sh` e il workflow GitHub Actions gestiscono questa scelta automaticamente.