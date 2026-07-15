#!/bin/bash
# Deploy de Taskko en bichosrv (Docker, mismo patrón que kollektor).
# Uso: cd ~/taskko && ./deploy.sh
set -e

echo "=== Pulling latest code ==="
cd ~/taskko
git pull origin main

echo "=== Rebuilding containers ==="
docker compose down
docker compose build
docker compose up -d

echo "=== Preparing database (create/schema/migrate, idempotente) ==="
sleep 5
docker compose exec -T web ./bin/rails db:prepare

echo "=== Done! ==="
docker compose ps
