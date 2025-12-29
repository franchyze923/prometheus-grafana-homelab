# Homelab Monitoring with Prometheus & Grafana

A simple monitoring setup to learn Prometheus and Grafana by monitoring your homelab servers.

## What is this?

- **Prometheus**: Collects metrics (CPU, memory, disk, network) from your servers every 15 seconds
- **Grafana**: Creates nice dashboards to visualize those metrics
- **Node Exporter**: Runs on each server you want to monitor and exposes metrics for Prometheus to collect

## Architecture

```
[Your Homelab Server 192.168.40.112]
         |
         | (node_exporter on port 9100)
         | exposes metrics
         ↓
    [Prometheus on port 9090]
         | stores metrics
         ↓
    [Grafana on port 3001]
         | visualizes metrics
```

## Setup Instructions

### Step 1: Install Node Exporter on your homelab server (192.168.40.112)

SSH into your homelab server and run:

```bash
# Download node_exporter
wget https://github.com/prometheus/node_exporter/releases/download/v1.8.2/node_exporter-1.8.2.linux-amd64.tar.gz

# Extract it
tar xvfz node_exporter-1.8.2.linux-amd64.tar.gz

# Move to /usr/local/bin
sudo mv node_exporter-1.8.2.linux-amd64/node_exporter /usr/local/bin/

# Clean up
rm -rf node_exporter-1.8.2.linux-amd64*
```

Create a systemd service to run it automatically:

```bash
sudo tee /etc/systemd/system/node_exporter.service > /dev/null <<EOF
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=nobody
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF
```

Start and enable the service:

```bash
sudo systemctl daemon-reload
sudo systemctl start node_exporter
sudo systemctl enable node_exporter
sudo systemctl status node_exporter
```

Verify it's working:
```bash
curl http://localhost:9100/metrics
```

You should see lots of metrics output!

### Step 2: Start Prometheus and Grafana

On your monitoring machine (where these files are), run:

```bash
docker-compose up -d
```

This starts both Prometheus and Grafana in the background.

Check they're running:
```bash
docker-compose ps
```

### Step 3: Verify Prometheus is collecting metrics

1. Open your browser to `http://localhost:9090`
2. Click on "Status" → "Targets"
3. You should see both `prometheus` and `homelab-server` targets with status "UP"
4. Try a query: Click "Graph" and type `node_cpu_seconds_total` then click "Execute"

### Step 4: Configure Grafana

1. Open your browser to `http://localhost:3001`
2. Login with:
   - Username: `admin`
   - Password: `admin`
   - (You'll be asked to change it - you can skip this for learning)

3. Add Prometheus as a data source:
   - Click the menu (☰) → "Connections" → "Data sources"
   - Click "Add data source"
   - Choose "Prometheus"
   - Set URL to: `http://prometheus:9090`
   - Click "Save & Test" (should show a green success message)

4. Import a dashboard:
   - Click the menu (☰) → "Dashboards"
   - Click "New" → "Import"
   - Enter dashboard ID: `1860` (this is a popular Node Exporter dashboard)
   - Click "Load"
   - Select "Prometheus" as the data source
   - Click "Import"

You should now see a beautiful dashboard with CPU, memory, disk, and network metrics from your homelab server!

## Useful Commands

```bash
# Start the monitoring stack
docker-compose up -d

# Stop the monitoring stack
docker-compose down

# View logs
docker-compose logs -f

# Restart after config changes
docker-compose restart prometheus
```

## What's happening?

1. **Node Exporter** on 192.168.40.112 exposes system metrics on port 9100
2. **Prometheus** scrapes (pulls) those metrics every 15 seconds and stores them
3. **Grafana** queries Prometheus and displays the data in dashboards

## Files Explained

- `docker-compose.yml`: Defines the Prometheus and Grafana containers
- `prometheus.yml`: Tells Prometheus where to scrape metrics from (your homelab server)

## Adding More Servers

To monitor more servers:
1. Install node_exporter on each server (Step 1)
2. Add them to `prometheus.yml` under the `homelab-server` job
3. Restart Prometheus: `docker-compose restart prometheus`

## Troubleshooting

**Target shows as "DOWN" in Prometheus:**
- Check if node_exporter is running: `systemctl status node_exporter`
- Check if port 9100 is accessible: `curl http://192.168.40.112:9100/metrics`
- Check firewall rules on the target server

**Can't access Grafana/Prometheus:**
- Check containers are running: `docker-compose ps`
- Check logs: `docker-compose logs`

**No data in Grafana:**
- Verify Prometheus data source is configured correctly
- Check Prometheus can reach the target (Status → Targets)
