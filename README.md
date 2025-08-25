# Monitoring Stack

A simple, reproducible monitoring stack with Docker Compose:
- **Prometheus** — scrape metrics and evaluate alert rules
- **Alertmanager** — route, group, and notify on alerts
- **Grafana** — dashboards, alerting UI, and visualization
- **InfluxDB** — time-series store for Telegraf metrics
- **Telegraf** — system & Docker metrics agent
- **SNMP Exporter** — monitor network devices via SNMP


---

## Requirements
- Docker & Docker Compose
- Free ports on host: `3000` (Grafana), `9090` (Prometheus), `9093` (Alertmanager), `8086` (InfluxDB), `9116` (SNMP Exporter)

---

## Quick start

```bash
git clone https://github.com/nghianguyen98/monitor-stack.git
cd monitoring-stack

cp .env.example .env   # edit if needed
docker compose up -d
```

- Grafana → http://localhost:3000  (credentials from `.env`)
- Prometheus → http://localhost:9090
- Alertmanager → http://localhost:9093
- InfluxDB → http://localhost:8086
- SNMP Exporter → http://localhost:9116/metrics

---

## Configuration layout

```
.
├─ .env.example                # copy to .env and adjust
├─ docker-compose.yaml         # one command to bring the stack up
├─ prometheus/
│  ├─ prometheus.yml           # core scrape & alerting config
│  └─ rules/
│     └─ example.rules.yml     # sample alert rules
├─ alertmanager/
│  └─ alertmanager.yml         # routes & receivers (edit to add notifications)
├─ grafana/
│  └─ provisioning/
│     ├─ datasources/
│     │  └─ datasources.yml    # provision Prometheus & InfluxDB
│     └─ dashboards/
│        ├─ dashboards.yml     # auto-load dashboards from ./examples
│        └─ examples/
│           └─ infra-overview.json
├─ telegraf/
│  └─ telegraf.conf            # collect system/docker → InfluxDB
└─ snmp_exporter/
   └─ snmp.yml                 # minimal module; adjust for your devices
```

### Prometheus
- Edit `prometheus/prometheus.yml` to add scrape targets / relabel rules.
- Put additional rules into `prometheus/rules/*.yml`.

### Alertmanager
- Configure your notification channels in `alertmanager/alertmanager.yml`
  (email, Slack, Telegram, webhooks, etc.).

### Grafana
- Datasources and dashboards are provisioned automatically.
- Drop any JSON dashboards into `grafana/provisioning/dashboards/examples/`.

### Telegraf
- `telegraf/telegraf.conf` collects Linux & Docker metrics by default.

### SNMP Exporter
- `snmp_exporter/snmp.yml` includes a tiny `if_mib` module as a starter.
- Query pattern (example): `/snmp?module=if_mib&target=192.0.2.10`.

---

## Production notes
- Pin image versions in `.env` (avoid `latest` for stability).
- Change all default passwords and restrict exposed ports with a firewall.

---

## License
MIT — do what you want; attribute and no warranty.
