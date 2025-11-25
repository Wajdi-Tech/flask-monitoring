#!/bin/bash
set -euo pipefail

echo "=== Test CI/CD – Démarrage du conteneur de test ==="
docker rm -f flask-test 2>/dev/null || true

# Build rapide de l'image fraîche (au cas où)
docker build -t flask-monitoring-app .

# Lancement en arrière-plan
docker run -d --name flask-test -p 5000:5000 flask-monitoring-app

# Attente active intelligente (max 30s)
for i in {1..30}; do
    if curl -f -s http://localhost:5000/health >/dev/null 2>&1; then
        echo "Application prête en ${i}s !"
        docker stop flask-test && docker rm flask-test
        exit 0
    fi
    sleep 1
done

echo "ERREUR : l'application n'a pas répondu en 30s"
docker logs flask-test
docker stop flask-test && docker rm flask-test
exit 1
