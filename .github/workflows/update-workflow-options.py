#!/usr/bin/env python3
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

            # REGEX RIGOROSO: solo X.Y.Z
            if re.match(r'^\d+\.\d+\.\d+$', name):
                if not any(x in name.lower() for x in ['alpha', 'beta', 'rc', 'dev', 'snapshot']):
                    versions.append(name)

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

def get_available_clienti():
    """Recupera i clienti disponibili dalla struttura clienti/"""
    try:
        result = subprocess.run(
            ["find", "clienti", "-maxdepth", "1", "-type", "d"],
            capture_output=True,
            text=True
        )

        clienti = [
            d.split('/')[-1] for d in result.stdout.strip().split('\n')
            if d and d != 'clienti' and d.strip()
        ]

        print(f"✅ Trovati {len(clienti)} clienti:")
        for c in clienti:
            print(f"   - {c}")
        return sorted(clienti)

    except Exception as e:
        print(f"❌ Errore nel recuperare clienti: {e}", file=sys.stderr)
        import traceback
        traceback.print_exc()
        return []

def update_workflow(versions, clienti):
    """Aggiorna il file workflow con le nuove opzioni"""
    workflow_path = '.github/workflows/build-image.yml'

    try:
        # Leggi il file YAML
        with open(workflow_path, 'r') as f:
            content = f.read()

        # Parse YAML
        workflow = yaml.safe_load(content)

        # ✅ SOLUZIONE: Cerca la chiave 'on' in modo sicuro
        trigger_key = None
        for key in workflow.keys():
            if key == 'on' or str(key).lower() == 'on':
                trigger_key = key
                break

        if trigger_key is None:
            print(f"❌ Chiave 'on' non trovata nel workflow!", file=sys.stderr)
            print(f"Chiavi disponibili: {list(workflow.keys())}", file=sys.stderr)
            return False

        # Aggiorna gli input
        clienti_options = ['all'] + clienti
        version_options = versions

        # Accedi ai trigger e aggiorna
        if 'workflow_dispatch' in workflow[trigger_key]:
            workflow[trigger_key]['workflow_dispatch']['inputs']['client']['options'] = clienti_options
            workflow[trigger_key]['workflow_dispatch']['inputs']['keycloak_version']['options'] = version_options
        else:
            print("❌ workflow_dispatch non trovato nel trigger 'on'", file=sys.stderr)
            return False

        # Scrivi il file aggiornato
        with open(workflow_path, 'w') as f:
            yaml.dump(
                workflow,
                f,
                default_flow_style=False,
                sort_keys=False,
                allow_unicode=True
            )

        print(f"\n✅ Workflow aggiornato!")
        print(f"   Clienti ({len(clienti_options)}): {', '.join(clienti_options)}")
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
    clienti = get_available_clienti()

    print()
    if versions and clienti:
        if update_workflow(versions, clienti):
            print("\n🎉 Aggiornamento completato con successo!")
            sys.exit(0)

    print("\n❌ Impossibile recuperare versioni o clienti")
    sys.exit(1)
