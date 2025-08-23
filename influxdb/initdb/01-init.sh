#!/usr/bin/env sh
set -e

# --- Wait until InfluxDB HTTP is ready ---
echo "[init] Waiting for InfluxDB on :8086 ..."
until wget -qO- http://localhost:8086/ping >/dev/null 2>&1; do
  sleep 1
done
echo "[init] InfluxDB is up."

# --- Read envs (with sensible defaults) ---
ADMIN_USER="${INFLUXDB_ADMIN_USER:-admin}"
ADMIN_PASS="${INFLUXDB_ADMIN_PASSWORD:-admin123}"

# Telegraf (already used by your stack)
TELEGRAF_DB="${INFLUXDB_DB:-telegraf}"
TELEGRAF_USER="${INFLUXDB_USER:-telegraf}"
TELEGRAF_PASS="${INFLUXDB_PASSWORD:-telegraf123}"

# Proxmox (new, separate DB/user)
PROX_DB="${INFLUXDB_PROXMOX_DB:-proxmox}"
PROX_USER="${INFLUXDB_PROXMOX_USER:-proxmox}"
PROX_PASS="${INFLUXDB_PROXMOX_PASSWORD:-proxmox123}"

echo "[init] Creating admin user (idempotent) ..."
# NOTE: With auth-enabled=true, before any admin exists, unauthenticated queries are allowed.
influx -execute "CREATE USER \"$ADMIN_USER\" WITH PASSWORD '$ADMIN_PASS' WITH ALL PRIVILEGES" || true

echo "[init] Creating databases (telegraf/proxmox) ..."
influx -username "$ADMIN_USER" -password "$ADMIN_PASS" -execute "CREATE DATABASE \"$TELEGRAF_DB\"" || true
influx -username "$ADMIN_USER" -password "$ADMIN_PASS" -execute "CREATE DATABASE \"$PROX_DB\"" || true

echo "[init] Creating/Granting users for Telegraf ..."
influx -username "$ADMIN_USER" -password "$ADMIN_PASS" -execute "CREATE USER \"$TELEGRAF_USER\" WITH PASSWORD '$TELEGRAF_PASS'" || true
influx -username "$ADMIN_USER" -password "$ADMIN_PASS" -execute "GRANT ALL ON \"$TELEGRAF_DB\" TO \"$TELEGRAF_USER\"" || true

echo "[init] Creating/Granting user for Proxmox ..."
influx -username "$ADMIN_USER" -password "$ADMIN_PASS" -execute "CREATE USER \"$PROX_USER\" WITH PASSWORD '$PROX_PASS'" || true
influx -username "$ADMIN_USER" -password "$ADMIN_PASS" -execute "GRANT ALL ON \"$PROX_DB\" TO \"$PROX_USER\"" || true

echo "[init] Done."
