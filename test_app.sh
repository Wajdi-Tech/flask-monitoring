#!/bin/bash
set -euo pipefail

echo "=== TEST CI/CD – Build et test SANS port hôte (plus jamais de conflit) ==="

# Nettoyage
docker rm -f flask-test 2>/dev/null || true
docker rmi flask-monitoring-app 2>/dev/null || true

# Build frais
docker build -t flask-monitoring-app .

# Lancement SANS -p → aucun port exposé sur l’hôte
docker run -d --name flask-test --network host flask-monitoring-app || \
docker run -d --name flask-test flask-monitoring-app

# Attente que le conteneur soit vraiment prêt (max 45s)
for i in {1..45}; do
    if docker exec flask-test curl -s -f http://127.0.0.1:5000/health >/dev/null 2>&1 || \
       docker exec flask-test wget -q -O - http://127.0.0.1:5000/health >/dev/null 2>&1; then
        echo "Application prête en ${i}s !"
        docker stop flask-test >/dev/null
        docker rm flask-test >/dev/null
        exit 0
    fi
    sleep 1
done

echo "ERREUR : l'application n'a pas répondu en 45s"
docker logs flask-test
docker stop flask-test && docker rm flask-test
exit 1
