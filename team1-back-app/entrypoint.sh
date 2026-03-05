#!/bin/sh
set -e

echo "Running database migrations..."
export DATABASE_URL="postgresql://${DB_USER}:${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_NAME}?schema=${DB_SCHEMA}"
node_modules/.bin/prisma migrate deploy

echo "Starting application..."
exec node dist/index.js
