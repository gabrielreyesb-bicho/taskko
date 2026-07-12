#!/bin/bash
# Deploy de todos en bichosrv (Docker, mismo patrón que kollektor).
# Uso: cd ~/todos && ./deploy.sh
set -e

echo "=== Pulling latest code ==="
cd ~/todos
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
