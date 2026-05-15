# Keycloak multi-cliente in locale con Docker Compose

Questo progetto contiene un'unica codebase Keycloak con più clienti dentro la cartella `clienti/`.

L'obiettivo è poter avviare in locale un container Keycloak scegliendo:

- la versione di Keycloak
- il cliente da testare
- il tema da modificare
- un server SMTP locale di test per verificare le email

Il tutto senza dover ricostruire l'immagine Docker ogni volta che si modifica HTML, CSS, immagini o template `.ftl`.

---

## Obiettivo della configurazione

La configurazione locale serve per lavorare velocemente sui temi Keycloak.

In particolare permette di:

- avviare Keycloak in locale
- scegliere il cliente tramite variabile `CLIENT_ID`
- scegliere la versione Keycloak tramite variabile `KEYCLOAK_VERSION`
- montare la cartella dei temi del cliente direttamente nel container
- modificare file `.ftl`, CSS, immagini e testi email con effetto quasi immediato
- testare l'invio email tramite Mailpit
- intercettare le email senza inviarle realmente verso internet

---

## Struttura del repository

La struttura consigliata è questa:

```text
eggsnext-keycloak-multi-client/
├── Dockerfile
├── docker-compose.yml
├── .env
├── README.md
├── base/
│   └── extensions/
│       └── eventuali-provider-custom.jar
└── clienti/
    ├── errevi/
    │   ├── themes/
    │   │   └── errevi-theme/
    │   │       ├── admin/
    │   │       ├── email/
    │   │       └── login/
    │   └── config.env
    │
    ├── errezeta/
    │   ├── themes/
    │   │   └── errezeta-theme/
    │   │       └── login/
    │   └── config.env
    │
    └── altro-cliente/
        ├── themes/
        │   └── altro-cliente-theme/
        └── config.env
```

La cartella importante è:

```text
clienti/<CLIENT_ID>/themes
```

Esempio:

```text
clienti/errevi/themes
```

Se nel file `.env` imposto:

```env
CLIENT_ID=errevi
```

Docker Compose monterà questa cartella nel container Keycloak:

```text
./clienti/errevi/themes:/opt/keycloak/themes
```

---

## Concetto principale

Il `Dockerfile` serve a costruire una base Keycloak generica.

Il `docker-compose.yml` serve invece a scegliere il cliente e montare i temi in live reload.

Quindi:

- in produzione o GitHub Actions puoi creare immagini cliente-specifiche
- in locale puoi usare bind mount per modificare i temi senza rebuild continuo

---

## Dockerfile

Il `Dockerfile` consigliato per lo sviluppo multi-cliente è generico.

```dockerfile
# Stage 0: argomenti globali
ARG KEYCLOAK_VERSION=26.6.1

# Stage 1: Builder
FROM quay.io/keycloak/keycloak:${KEYCLOAK_VERSION} AS builder

# Provider custom comuni a tutti i clienti
# Se hai estensioni .jar, normalmente in Keycloak recente vanno in /opt/keycloak/providers
COPY base/extensions /opt/keycloak/providers

RUN /opt/keycloak/bin/kc.sh build

# Stage 2: Runtime
FROM quay.io/keycloak/keycloak:${KEYCLOAK_VERSION}

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

### Perché il Dockerfile non copia più `clienti/<CLIENT_ID>/themes`

Nel Dockerfile originale c'erano righe simili:

```dockerfile
COPY clienti/${CLIENT_ID}/themes /opt/keycloak/themes
COPY clienti/${CLIENT_ID}/config.env /opt/keycloak/.env
```

Queste righe vanno bene per una build statica, ad esempio in CI/CD.

Per lo sviluppo locale, però, sono scomode perché ogni modifica al tema richiede una nuova build dell'immagine.

In locale è meglio montare la cartella con Docker Compose:

```yaml
volumes:
  - ./clienti/${CLIENT_ID}/themes:/opt/keycloak/themes
```

Così ogni modifica fatta nel progetto viene vista dal container.

---

## docker-compose.yml

Crea questo file nella root del repository.

```yaml
services:
  keycloak:
    build:
      context: .
      dockerfile: Dockerfile
      args:
        KEYCLOAK_VERSION: ${KEYCLOAK_VERSION:-26.6.1}

    container_name: keycloak-${CLIENT_ID:-errevi}

    ports:
      - "${KEYCLOAK_PORT:-8080}:8080"

    env_file:
      - ./clienti/${CLIENT_ID:-errevi}/config.env

    environment:
      KC_BOOTSTRAP_ADMIN_USERNAME: ${KEYCLOAK_ADMIN_USER:-admin}
      KC_BOOTSTRAP_ADMIN_PASSWORD: ${KEYCLOAK_ADMIN_PASSWORD:-admin}

      KEYCLOAK_ADMIN: ${KEYCLOAK_ADMIN_USER:-admin}
      KEYCLOAK_ADMIN_PASSWORD: ${KEYCLOAK_ADMIN_PASSWORD:-admin}

      KC_HTTP_ENABLED: "true"
      KC_HOSTNAME_STRICT: "false"
      KC_HOSTNAME_STRICT_HTTPS: "false"

    volumes:
      # Live reload dei temi del cliente selezionato
      - ./clienti/${CLIENT_ID:-errevi}/themes:/opt/keycloak/themes

      # Volume dati locale Keycloak
      - keycloak-data:/opt/keycloak/data

    command:
      - start-dev
      - --spi-theme-static-max-age=-1
      - --spi-theme-cache-themes=false
      - --spi-theme-cache-templates=false

    depends_on:
      - mailpit

  mailpit:
    image: axllent/mailpit:latest
    container_name: mailpit-${CLIENT_ID:-errevi}
    ports:
      - "${MAILPIT_SMTP_PORT:-1025}:1025"
      - "${MAILPIT_WEB_PORT:-8025}:8025"

volumes:
  keycloak-data:
```

---

## File `.env`

Crea un file `.env` nella root del progetto.

```env
CLIENT_ID=errevi
KEYCLOAK_VERSION=26.6.1

KEYCLOAK_PORT=8080
KEYCLOAK_ADMIN_USER=admin
KEYCLOAK_ADMIN_PASSWORD=admin

MAILPIT_SMTP_PORT=1025
MAILPIT_WEB_PORT=8025
```

Questo file permette di evitare di scrivere ogni volta le variabili nel comando.

---

## Come avviare Keycloak in locale

Dalla root del repository:

```bash
docker compose up --build
```

Keycloak sarà disponibile su:

```text
http://localhost:8080
```

Mailpit sarà disponibile su:

```text
http://localhost:8025
```

Credenziali admin Keycloak:

```text
username: admin
password: admin
```

---

## Come avviare un cliente specifico

Puoi scegliere il cliente modificando il file `.env`:

```env
CLIENT_ID=errevi
```

Oppure direttamente da terminale:

```bash
CLIENT_ID=errevi docker compose up --build
```

Per un altro cliente:

```bash
CLIENT_ID=errezeta docker compose up --build
```

Per cambiare anche versione Keycloak:

```bash
CLIENT_ID=errevi KEYCLOAK_VERSION=26.6.1 docker compose up --build
```

---

## Come funziona il live reload dei temi

La riga fondamentale è questa:

```yaml
volumes:
  - ./clienti/${CLIENT_ID:-errevi}/themes:/opt/keycloak/themes
```

Significa che la cartella locale:

```text
clienti/errevi/themes
```

viene montata dentro il container in:

```text
/opt/keycloak/themes
```

Quindi, se modifichi ad esempio:

```text
clienti/errevi/themes/errevi-theme/login/resources/css/style.css
```

il container vede subito la modifica.

Non devi ricostruire l'immagine Docker.

Di solito basta fare refresh del browser.

Per CSS e immagini può servire un refresh forzato:

```text
CTRL + F5
```

Oppure disabilitare la cache dal DevTools del browser.

---

## Perché si usa `start-dev`

Nel Docker Compose viene usato:

```yaml
command:
  - start-dev
```

`start-dev` è più comodo in locale perché avvia Keycloak in modalità sviluppo.

Per ambienti di produzione è invece preferibile usare:

```bash
kc.sh start --optimized
```

Nel Dockerfile può rimanere un'immagine generica, mentre il Compose decide come avviare il container in locale.

---

## Cache dei temi disabilitata

Nel Compose vengono passati questi parametri:

```yaml
command:
  - start-dev
  - --spi-theme-static-max-age=-1
  - --spi-theme-cache-themes=false
  - --spi-theme-cache-templates=false
```

Servono per evitare che Keycloak mantenga in cache i temi.

Significato:

```text
--spi-theme-static-max-age=-1
```

Disabilita la cache dei file statici dei temi.

```text
--spi-theme-cache-themes=false
```

Disabilita la cache della struttura dei temi.

```text
--spi-theme-cache-templates=false
```

Disabilita la cache dei template FreeMarker `.ftl`.

Questo è importante mentre si modificano:

```text
login.ftl
password-reset.ftl
template.ftl
messages_it.properties
style.css
immagini
```

---

## Quando serve comunque riavviare Keycloak

Il live reload funziona bene per:

- CSS
- immagini
- template `.ftl`
- file `messages_*.properties`

Però in alcuni casi conviene riavviare Keycloak:

- hai aggiunto una nuova cartella tema
- hai cambiato `theme.properties`
- hai cambiato nome tema
- hai modificato provider `.jar`
- hai cambiato file dentro `base/extensions`
- hai cambiato variabili nel file `config.env`

Riavvio:

```bash
docker compose restart keycloak
```

Ricostruzione completa:

```bash
docker compose up --build
```

Pulizia totale con rimozione volumi:

```bash
docker compose down -v
docker compose up --build
```

---

## Come pulire la cache interna dei temi

Se non vedi le modifiche, puoi pulire la cache interna di Keycloak:

```bash
docker compose exec keycloak rm -rf /opt/keycloak/data/tmp/kc-gzip-cache
```

Poi fai refresh del browser.

Se il container ha un nome diverso e il comando non funziona, usa:

```bash
docker ps
```

e poi entra nel container:

```bash
docker exec -it nome-container bash
```

---

## Come impostare il tema in Keycloak

Dopo aver avviato Keycloak, entra nella Admin Console:

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

Imposta i temi desiderati.

Esempio per Errevi:

```text
Login theme: errevi-theme
Email theme: errevi-theme
Admin theme: errevi-theme
```

Il nome visibile in Keycloak corrisponde al nome della cartella tema.

Esempio:

```text
clienti/errevi/themes/errevi-theme
```

diventa:

```text
errevi-theme
```

---

## Tema email

Per personalizzare le email Keycloak devi avere una struttura simile:

```text
clienti/errevi/themes/errevi-theme/email/
├── theme.properties
├── messages/
│   ├── messages_it.properties
│   └── messages_en.properties
├── html/
│   └── password-reset.ftl
├── text/
│   └── password-reset.ftl
└── resources/
    └── img/
        └── logo-errevi.png
```

Il reset password usa questi file:

```text
email/html/password-reset.ftl
email/text/password-reset.ftl
email/messages/messages_it.properties
```

---

## Mailpit per test email

Il Compose include anche Mailpit:

```yaml
mailpit:
  image: axllent/mailpit:latest
  ports:
    - "1025:1025"
    - "8025:8025"
```

Mailpit è un server SMTP locale di test.

Keycloak invia le email a Mailpit, ma Mailpit non le spedisce realmente.

Le email vengono mostrate in una web UI.

Indirizzo Mailpit:

```text
http://localhost:8025
```

---

## Configurazione SMTP Keycloak per Mailpit

Dentro Keycloak vai in:

```text
Realm settings → Email
```

Configura così:

```text
Host: mailpit
Port: 1025
From: noreply@erreviautomation.com
From display name: Errevi Automation
Authentication: OFF
Encryption: NONE
```

Importante: usare `mailpit`, non `localhost`.

Motivo:

- Keycloak gira dentro un container
- dentro il container `localhost` indica il container Keycloak stesso
- `mailpit` è il nome del servizio Docker Compose
- Docker Compose crea automaticamente una rete interna dove i servizi si raggiungono per nome

---

## Come testare email reset password

Prima assicurati di avere configurato il tema email:

```text
Realm settings → Themes → Email theme
```

Poi configura SMTP:

```text
Realm settings → Email
```

Clicca:

```text
Test connection
```

Poi crea o scegli un utente:

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

Poi invia l'email di reset:

```text
Users → test-reset → Credentials / Required actions
```

Cerca l'azione:

```text
Execute actions email
```

Seleziona:

```text
UPDATE_PASSWORD
```

Invia.

Poi apri:

```text
http://localhost:8025
```

Vedrai l'email intercettata da Mailpit.

---

## Perché usare un unico Compose

Un Compose parametrico evita di creare un file diverso per ogni cliente.

Invece di avere:

```text
docker-compose-errevi.yml
docker-compose-errezeta.yml
docker-compose-cliente-x.yml
```

usi un solo file:

```text
docker-compose.yml
```

e cambi solo:

```env
CLIENT_ID=errevi
```

oppure lanci:

```bash
CLIENT_ID=errezeta docker compose up --build
```

---

## Differenza tra ambiente locale e build CI/CD

### Locale

In locale vuoi modificare velocemente i temi.

Quindi usi:

```yaml
volumes:
  - ./clienti/${CLIENT_ID}/themes:/opt/keycloak/themes
```

Vantaggio:

- niente rebuild per ogni modifica
- sviluppo più veloce
- test immediato su browser e email

### CI/CD o GitHub Actions

In CI/CD è meglio creare un'immagine chiusa e riproducibile.

In quel caso puoi usare una build con:

```bash
docker build   --build-arg KEYCLOAK_VERSION=26.6.1   --build-arg CLIENT_ID=errevi   -t keycloak-errevi:26.6.1 .
```

E nel Dockerfile puoi scegliere se copiare anche i temi dentro l'immagine.

Quindi il principio è:

```text
Locale = bind mount
CI/CD = immagine statica
```

---

## Possibile Dockerfile per CI/CD cliente-specifico

Se vuoi mantenere una build cliente-specifica per GitHub Actions, puoi tenere un Dockerfile separato, ad esempio:

```text
Dockerfile.ci
```

E dentro usare:

```dockerfile
ARG KEYCLOAK_VERSION=26.6.1
ARG CLIENT_ID

FROM quay.io/keycloak/keycloak:${KEYCLOAK_VERSION} AS builder

ARG CLIENT_ID

COPY base/extensions /opt/keycloak/providers

RUN /opt/keycloak/bin/kc.sh build

FROM quay.io/keycloak/keycloak:${KEYCLOAK_VERSION}

ARG CLIENT_ID

COPY --from=builder /opt/keycloak/ /opt/keycloak/
COPY clienti/${CLIENT_ID}/themes /opt/keycloak/themes
COPY clienti/${CLIENT_ID}/config.env /opt/keycloak/.env

ENV KC_HTTP_ENABLED=true
ENV KC_HOSTNAME_STRICT=false
ENV KC_HOSTNAME_STRICT_HTTPS=false

ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]
CMD ["start", "--optimized"]
```

Così hai:

```text
Dockerfile        → sviluppo locale generico
Dockerfile.ci     → build statica per deploy
docker-compose.yml → avvio locale parametrico
```

---

## Comandi utili

Avvio normale:

```bash
docker compose up --build
```

Avvio in background:

```bash
docker compose up --build -d
```

Log Keycloak:

```bash
docker compose logs -f keycloak
```

Stop:

```bash
docker compose down
```

Stop con rimozione volumi:

```bash
docker compose down -v
```

Riavvio solo Keycloak:

```bash
docker compose restart keycloak
```

Ricostruzione senza cache:

```bash
docker compose build --no-cache
docker compose up
```

Entrare nel container Keycloak:

```bash
docker compose exec keycloak bash
```

Verificare i temi dentro il container:

```bash
docker compose exec keycloak ls -la /opt/keycloak/themes
```

Verificare un tema specifico:

```bash
docker compose exec keycloak ls -la /opt/keycloak/themes/errevi-theme
```

---

## Problemi comuni

### Il tema non compare nella lista Keycloak

Controlla che la struttura sia corretta:

```text
clienti/errevi/themes/errevi-theme/login/theme.properties
```

oppure:

```text
clienti/errevi/themes/errevi-theme/email/theme.properties
```

Poi riavvia:

```bash
docker compose restart keycloak
```

---

### Modifico il CSS ma non cambia nulla

Prova:

```text
CTRL + F5
```

Oppure disabilita la cache dal DevTools del browser.

Poi pulisci la cache Keycloak:

```bash
docker compose exec keycloak rm -rf /opt/keycloak/data/tmp/kc-gzip-cache
```

---

### Mailpit non riceve email

Controlla in Keycloak:

```text
Realm settings → Email
```

I valori devono essere:

```text
Host: mailpit
Port: 1025
Authentication: OFF
Encryption: NONE
```

Non usare:

```text
localhost
```

perché Keycloak è dentro Docker.

---

### Keycloak non parte dopo cambio versione

Fai pulizia:

```bash
docker compose down -v
docker compose build --no-cache
docker compose up
```

Se hai provider custom, verifica che siano compatibili con la versione Keycloak scelta.

---

### Errore sul file `config.env`

Il Compose usa:

```yaml
env_file:
  - ./clienti/${CLIENT_ID:-errevi}/config.env
```

Quindi deve esistere questo file:

```text
clienti/errevi/config.env
```

Se non hai variabili specifiche, puoi creare un file vuoto.

---

## Esempio file `config.env`

Per un cliente puoi avere:

```env
KC_LOG_LEVEL=info
KC_HTTP_RELATIVE_PATH=/
```

Oppure lasciarlo vuoto se non serve.

---

## Workflow consigliato

1. Imposta il cliente nel file `.env`:

```env
CLIENT_ID=errevi
```

2. Avvia i container:

```bash
docker compose up --build
```

3. Apri Keycloak:

```text
http://localhost:8080
```

4. Entra con:

```text
admin / admin
```

5. Imposta il tema:

```text
Realm settings → Themes
```

6. Configura SMTP con Mailpit:

```text
Realm settings → Email
```

7. Modifica i file tema da IDE:

```text
clienti/errevi/themes/errevi-theme
```

8. Fai refresh browser.

9. Testa email su:

```text
http://localhost:8025
```

---

## Riepilogo

Questa configurazione permette di usare un solo repository Keycloak multi-cliente.

Il cliente viene scelto tramite:

```env
CLIENT_ID=errevi
```

La versione Keycloak viene scelta tramite:

```env
KEYCLOAK_VERSION=26.6.1
```

I temi vengono montati live tramite:

```yaml
volumes:
  - ./clienti/${CLIENT_ID}/themes:/opt/keycloak/themes
```

Le email vengono testate con Mailpit:

```text
http://localhost:8025
```

La configurazione è quindi adatta per sviluppo locale, test grafici dei temi, test email e validazione rapida delle personalizzazioni cliente.
