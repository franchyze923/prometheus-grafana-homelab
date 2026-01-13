# Weight Dashboard Integration Setup

This guide explains how to integrate your weight dashboard API with Prometheus and Grafana.

## Architecture

1. **Weight Dashboard App** (`http://192.168.40.13:5000/api/weights`) - Your Flask app that fetches data from Withings API
2. **Weight Exporter** (port 9101) - Python service that converts weight data to Prometheus metrics
3. **Prometheus** (port 9090) - Scrapes metrics from the weight exporter
4. **Grafana** (port 3001) - Visualizes the metrics

## Files Created

- `weight-exporter.py` - Prometheus exporter for body composition metrics
- `requirements-exporter.txt` - Python dependencies
- `Dockerfile.weight-exporter` - Docker image for the exporter
- Updated `prometheus.yml` - Added weight-dashboard scrape config
- Updated `docker-compose.yml` - Added weight-exporter service

## Deployment Steps

1. **Build and start the services:**
   ```bash
   cd /home/fran/grafana-prom-homelab
   docker-compose up -d --build
   ```

2. **Verify the exporter is running:**
   ```bash
   docker-compose logs weight-exporter
   curl http://localhost:9101/metrics
   ```

3. **Check Prometheus is scraping:**
   - Open http://localhost:9090
   - Go to Status → Targets
   - Look for the `weight-dashboard` job
   - Should show state "UP"

4. **Query metrics in Prometheus:**
   - Try queries like:
     - `body_weight_pounds`
     - `body_fat_percent`
     - `body_muscle_mass_pounds`

## Available Metrics

The exporter exposes these metrics:

- `body_weight_pounds` / `body_weight_kilograms` - Total body weight
- `body_fat_percent` - Body fat percentage
- `body_fat_mass_pounds` / `body_fat_mass_kilograms` - Fat mass
- `body_muscle_mass_pounds` / `body_muscle_mass_kilograms` - Muscle mass
- `body_hydration_pounds` / `body_hydration_kilograms` - Body hydration
- `body_bone_mass_pounds` / `body_bone_mass_kilograms` - Bone mass
- `body_fat_free_mass_pounds` / `body_fat_free_mass_kilograms` - Fat-free mass
- `body_measurement_timestamp` - Unix timestamp of measurement
- `body_measurement_info` - Metadata about the measurement

## Creating Grafana Dashboards

1. Open Grafana at http://localhost:3001 (admin/admin)
2. Create a new dashboard
3. Add panels with queries like:
   - Weight over time: `body_weight_pounds`
   - Body fat %: `body_fat_percent`
   - Muscle mass: `body_muscle_mass_pounds`

## Troubleshooting

1. **Exporter can't reach weight API:**
   - Verify weight dashboard is running: `curl http://192.168.40.13:5000/api/weights`
   - Check network connectivity from container

2. **Prometheus not scraping:**
   - Check Prometheus logs: `docker-compose logs prometheus`
   - Verify prometheus.yml is mounted correctly
   - Restart Prometheus: `docker-compose restart prometheus`

3. **No data in Grafana:**
   - Verify Prometheus data source is configured in Grafana
   - Check that metrics exist in Prometheus first

## Configuration

Environment variables in docker-compose.yml:
- `WEIGHT_API_URL` - URL to your weight dashboard API
- `EXPORTER_PORT` - Port for the exporter (default: 9101)
- `SCRAPE_INTERVAL` - How often to fetch new data in seconds (default: 300)
