#!/usr/bin/env python3
"""
Script per aggiornare automaticamente i dropdown del workflow
con le versioni e i client disponibili
"""

import json
import subprocess
import requests
import yaml
import sys
import re

def get_keycloak_versions(limit=20):
    """Recupera le versioni disponibili da Quay.io"""
    try:
        response = requests.get(
            'https://quay.io/api/v1/repository/keycloak/keycloak/tag?limit=100',
            timeout=10
        )
        response.raise_for_status()

        tags = response.json().get('tags', [])
        versions = []

        for tag in tags:
            name = tag.get('name', '')

            # ✅ REGEX RIGOROSO: solo X.Y.Z (es: 24.0.0, 23.0.1)
            if re.match(r'^\d+\.\d+\.\d+$', name):
                # Esclude alpha, beta, rc, dev, snapshot
                if not any(x in name.lower() for x in ['alpha', 'beta', 'rc', 'dev', 'snapshot']):
                    versions.append(name)

        # Rimuovi duplicati e ordina in discendente
        versions = sorted(
            set(versions),
            key=lambda x: tuple(map(int, x.split('.'))),
            reverse=True
        )

        print(f"✅ Trovate {len(versions)} versioni valide")
        for v in versions[:5]:
            print(f"   - {v}")
        return versions[:limit]

    except Exception as e:
        print(f"❌ Errore nel recuperare versioni: {e}", file=sys.stderr)
        import traceback
        traceback.print_exc()
        return []

def get_available_clients():
    """Recupera i client disponibili dalla struttura"""
    try:
        result = subprocess.run(
            ["find", "clienti", "-maxdepth", "1", "-type", "d"],
            capture_output=True,
            text=True
        )

        clients = [
            d.split('/')[-1] for d in result.stdout.strip().split('\n')
            if d and d != 'clienti' and d.strip()
        ]

        print(f"✅ Trovati {len(clients)} clienti:")
        for c in clients:
            print(f"   - {c}")
        return sorted(clients)

    except Exception as e:
        print(f"❌ Errore nel recuperare client: {e}", file=sys.stderr)
        import traceback
        traceback.print_exc()
        return []

def update_workflow(versions, clients):
    """Aggiorna il file workflow con le nuove opzioni"""
    workflow_path = '.github/workflows/build-image.yml'

    try:
        # Leggi il file YAML
        with open(workflow_path, 'r') as f:
            workflow = yaml.safe_load(f)

        # Aggiorna gli input
        client_options = ['all'] + clients
        version_options = versions

        workflow['on']['workflow_dispatch']['inputs']['client']['options'] = client_options
        workflow['on']['workflow_dispatch']['inputs']['keycloak_version']['options'] = version_options

        # Scrivi il file aggiornato con formato pulito
        with open(workflow_path, 'w') as f:
            yaml.dump(
                workflow,
                f,
                default_flow_style=False,
                sort_keys=False,
                allow_unicode=True
            )

        print(f"\n✅ Workflow aggiornato!")
        print(f"   Client ({len(client_options)}): {', '.join(client_options)}")
        print(f"   Versioni ({len(version_options)}): {', '.join(version_options[:5])}...")

        return True

    except Exception as e:
        print(f"❌ Errore nell'aggiornamento: {e}", file=sys.stderr)
        import traceback
        traceback.print_exc()
        return False

if __name__ == '__main__':
    print("🔄 Aggiornamento opzioni workflow...")
    print()

    versions = get_keycloak_versions(20)
    clients = get_available_clients()

    print()
    if versions and clients:
        if update_workflow(versions, clients):
            print("\n🎉 Aggiornamento completato con successo!")
            sys.exit(0)

    print("\n❌ Impossibile recuperare versioni o client")
    sys.exit(1)