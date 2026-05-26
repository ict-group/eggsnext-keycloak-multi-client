#!/usr/bin/env bash
# =============================================================================
# purge-all.sh — Purge completo Docker per keycloak-multi-client
# =============================================================================
# Uso: ./purge-all.sh [--force]
# --force  → salta la conferma interattiva (utile per External Tools IntelliJ)
# =============================================================================

set -euo pipefail

# Colori
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Trova la root del progetto (dove si trova questo script)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR"
COMPOSE_FILE="$PROJECT_ROOT/docker-compose-test.yml"

echo -e "${CYAN}"
echo "╔══════════════════════════════════════════════╗"
echo "║        🧹  KEYCLOAK MULTI-CLIENT PURGE       ║"
echo "╚══════════════════════════════════════════════╝"
echo -e "${NC}"

# Verifica che docker-compose-test.yml esista
if [ ! -f "$COMPOSE_FILE" ]; then
  echo -e "${RED}❌ Errore: non trovo $COMPOSE_FILE${NC}"
  echo "   Assicurati che lo script sia nella root del progetto."
  exit 1
fi

# Conferma interattiva (saltabile con --force)
FORCE=false
for arg in "$@"; do
  [[ "$arg" == "--force" ]] && FORCE=true
done

if [ "$FORCE" = false ]; then
  echo -e "${YELLOW}⚠️  Questo script eseguirà:${NC}"
  echo "   1. docker compose down --volumes --remove-orphans"
  echo "   2. docker system prune --all --volumes --force"
  echo ""
  echo -e "${RED}   Verranno rimossi TUTTI i container, volumi, immagini e cache non in uso.${NC}"
  echo ""
  read -r -p "   Sei sicuro? (s/N) " risposta
  case "$risposta" in
    [sS]) echo "" ;;
    *)
      echo -e "${YELLOW}Operazione annullata.${NC}"
      exit 0
      ;;
  esac
fi

# -----------------------------------------------------------------------------
# STEP 1 — docker compose down (tutti i servizi definiti nel compose)
# -----------------------------------------------------------------------------
echo -e "${CYAN}▶ [1/3] Arresto e rimozione container + volumi del progetto...${NC}"

if docker compose -f "$COMPOSE_FILE" down --volumes --remove-orphans 2>&1; then
  echo -e "${GREEN}   ✔ docker compose down completato${NC}"
else
  echo -e "${YELLOW}   ⚠ docker compose down ha restituito un warning (potrebbe essere già fermo)${NC}"
fi

echo ""

# -----------------------------------------------------------------------------
# STEP 2 — rimozione forzata di tutti i container (anche in esecuzione) e volumi named
# -----------------------------------------------------------------------------
echo -e "${CYAN}▶ [2/3] Rimozione forzata di tutti i container e volumi named...${NC}"

CONTAINERS=$(docker ps -aq)
if [ -n "$CONTAINERS" ]; then
  docker stop $CONTAINERS 2>/dev/null || true
  docker rm -f $CONTAINERS 2>/dev/null || true
  echo -e "${GREEN}   ✔ Container rimossi${NC}"
else
  echo "   Nessun container da rimuovere"
fi

VOLUMES=$(docker volume ls -q)
if [ -n "$VOLUMES" ]; then
  docker volume rm $VOLUMES 2>/dev/null || true
  echo -e "${GREEN}   ✔ Volumi named rimossi${NC}"
else
  echo "   Nessun volume named da rimuovere"
fi

echo ""

# -----------------------------------------------------------------------------
# STEP 3 — docker system prune globale (immagini, reti, build cache)
# -----------------------------------------------------------------------------
echo -e "${CYAN}▶ [3/3] Pulizia globale Docker (system prune)...${NC}"
echo "   Rimozione di: immagini, reti inutilizzate, volumi orfani, build cache"
echo ""

docker system prune --all --volumes --force

echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║        ✅  PURGE COMPLETATO                  ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════╝${NC}"
echo ""
echo "   Prossimi step:"
echo "   • Riavvia il cliente desiderato dalla Run Configuration in IntelliJ"
echo "   • Oppure: docker compose -f docker-compose-test.yml up <servizio>"
echo ""