#!/usr/bin/env python3
import requests
import yaml
import sys
import re
import subprocess

def get_keycloak_versions(limit=20):
    """Recupera l'ultima versione stabile per ogni Major release (>= 18)"""
    try:
        # Aumentiamo il limite a 1000 per essere sicuri di arrivare alla versione 18
        # Keycloak ha moltissimi tag tra patch e versioni candidate.
        response = requests.get(
            'https://quay.io/api/v1/repository/keycloak/keycloak/tag?limit=1000',
            timeout=15
        )
        response.raise_for_status()

        tags = response.json().get('tags', [])
        all_stable = []

        for tag in tags:
            name = tag.get('name', '')
            # Filtro rigoroso: solo X.Y.Z stabili
            if re.match(r'^\d+\.\d+\.\d+$', name):
                if not any(x in name.lower() for x in ['alpha', 'beta', 'rc', 'dev', 'snapshot']):
                    all_stable.append(name)

        # Ordina tutte le versioni in modo decrescente numerico
        all_stable.sort(key=lambda x: tuple(map(int, x.split('.'))), reverse=True)

        # LOGICA: Teniamo solo la più recente per ogni numero MAJOR
        latest_per_major = {}
        for v in all_stable:
            major = int(v.split('.')[0])
            # Consideriamo solo dalla 18 in su come richiesto
            if major >= 18:
                if major not in latest_per_major:
                    latest_per_major[major] = v

        # Estraiamo le versioni e ordiniamole (dalla 26 alla 18)
        filtered_versions = [latest_per_major[m] for m in sorted(latest_per_major.keys(), reverse=True)]

        print(f"✅ Trovate {len(filtered_versions)} versioni Major (18 -> {max(latest_per_major.keys())})")
        for v in filtered_versions:
            print(f"   - {v}")

        return filtered_versions[:limit]

    except Exception as e:
        print(f"❌ Errore nel recuperare versioni: {e}", file=sys.stderr)
        return []

def get_available_clienti():
    """Recupera i clienti disponibili dalla cartella clienti/"""
    try:
        # Nota: usiamo 'clients' se la tua cartella si chiama così nel repo
        result = subprocess.run(
            ["ls", "-d", "clients/*/"],
            capture_output=True,
            text=True
        )
        clienti = [
            d.split('/')[-2] for d in result.stdout.strip().split('\n')
            if d and 'clients/' in d
        ]
        return sorted(clienti)
    except:
        return ["errevi", "errezeta", "papalini", "poma"]

def update_workflow(versions, clienti):
    """Aggiorna build-image.yml"""
    workflow_path = '.github/workflows/build-image.yml'
    try:
        with open(workflow_path, 'r') as f:
            workflow = yaml.safe_load(f)

        # Aggiorna le opzioni nel file YAML
        # PyYAML legge 'on:' come True
        trigger = True
        workflow[trigger]['workflow_dispatch']['inputs']['client']['options'] = ['all'] + clienti
        workflow[trigger]['workflow_dispatch']['inputs']['keycloak_version']['options'] = versions

        with open(workflow_path, 'w') as f:
            yaml.dump(workflow, f, default_flow_style=False, sort_keys=False)

        # Correzione post-scrittura per ripristinare 'on:' invece di 'True:'
        with open(workflow_path, 'r') as f:
            lines = f.readlines()
        with open(workflow_path, 'w') as f:
            for line in lines:
                f.write(line.replace('True:', 'on:'))
        return True
    except Exception as e:
        print(f"Errore update: {e}")
        return False

if __name__ == '__main__':
    versions = get_keycloak_versions(20)
    clienti = get_available_clienti()
    if versions and update_workflow(versions, clienti):
        print("🎉 Workflow aggiornato con successo!")