#!/bin/bash
set -euo pipefail

echo "=== TEST CI/CD – Nettoyage et build frais ==="
docker rm -f flask-test 2>/dev/null || true
docker rmi flask-monitoring-app 2>/dev/null || true
docker build -t flask-monitoring-app .

echo "=== Démarrage du conteneur de test ==="
docker run -d --name flask-test -p 5000:5000 flask-monitoring-app

echo "=== Attente que /health (max 45s) ==="
for i in {1..45}; do
    if curl -s -f http://localhost:5000/health >/dev/null 2>&1; then
        echo "Application prête en ${i}s !"
        docker stop flask-test >/dev/null
        docker rm flask-test >/dev/null
        exit 0
    fi
    sleep 1
done

echo "ERREUR : timeout après 45s"
docker logs flask-test
docker stop flask-test && docker rm flask-test
exit 1
