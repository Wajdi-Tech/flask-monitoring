#!/bin/bash
set -e

echo "Démarrage du conteneur de test..."
docker run -d -p 5000:5000 --name flask-test flask-monitoring-app

echo "Attente du démarrage..."
sleep 8

echo "Test de disponibilité..."
response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:5000/health)

if [ "$response" -eq 200 ]; then
    echo "Application disponible (code $response)"
else
    echo "Application indisponible (code $response)"
    exit 1
fi

docker stop flask-test && docker rm flask-test
