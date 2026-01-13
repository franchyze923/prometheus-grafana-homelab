#!/bin/bash
# Script to automatically configure Prometheus data source in Grafana

GRAFANA_URL="http://localhost:3001"
GRAFANA_USER="admin"
GRAFANA_PASS=""

# Allow passing credentials as arguments
if [ $# -eq 2 ]; then
    GRAFANA_USER="$1"
    GRAFANA_PASS="$2"
fi

echo "Setting up Prometheus data source in Grafana..."
echo "Grafana URL: $GRAFANA_URL"

# Wait for Grafana to be ready
echo "Waiting for Grafana to be ready..."
for i in {1..30}; do
    if curl -s -f "$GRAFANA_URL/api/health" > /dev/null 2>&1; then
        echo "Grafana is ready!"
        break
    fi
    if [ $i -eq 30 ]; then
        echo "ERROR: Grafana did not become ready in time"
        exit 1
    fi
    echo "Waiting... ($i/30)"
    sleep 2
done

# Check if Prometheus data source already exists
echo "Checking for existing Prometheus data source..."
EXISTING_DS=$(curl -s -u "$GRAFANA_USER:$GRAFANA_PASS" \
    "$GRAFANA_URL/api/datasources/name/prometheus" \
    -w "\n%{http_code}" | tail -n1)

if [ "$EXISTING_DS" = "200" ]; then
    echo "Prometheus data source already exists. Skipping creation."
else
    echo "Creating Prometheus data source..."

    # Create the data source
    RESPONSE=$(curl -s -u "$GRAFANA_USER:$GRAFANA_PASS" \
        -X POST \
        -H "Content-Type: application/json" \
        -d '{
            "name": "prometheus",
            "type": "prometheus",
            "url": "http://prometheus:9090",
            "access": "proxy",
            "isDefault": true,
            "jsonData": {
                "httpMethod": "POST",
                "timeInterval": "15s"
            }
        }' \
        "$GRAFANA_URL/api/datasources")

    if echo "$RESPONSE" | grep -q '"id"'; then
        echo "✓ Prometheus data source created successfully!"
    elif echo "$RESPONSE" | grep -q "401"; then
        echo "ERROR: Authentication failed. Please provide correct credentials:"
        echo "Usage: $0 <username> <password>"
        echo ""
        echo "Or set environment variables:"
        echo "  export GRAFANA_USER=your_username"
        echo "  export GRAFANA_PASS=your_password"
        exit 1
    else
        echo "ERROR: Failed to create data source"
        echo "Response: $RESPONSE"
        exit 1
    fi
fi

# Import the dashboard
echo "Importing Body Composition Dashboard..."

DASHBOARD_JSON=$(cat weight-dashboard.json)

IMPORT_RESPONSE=$(curl -s -u "$GRAFANA_USER:$GRAFANA_PASS" \
    -X POST \
    -H "Content-Type: application/json" \
    -d "{
        \"dashboard\": $DASHBOARD_JSON,
        \"overwrite\": true,
        \"inputs\": [{
            \"name\": \"DS_PROMETHEUS\",
            \"type\": \"datasource\",
            \"pluginId\": \"prometheus\",
            \"value\": \"prometheus\"
        }]
    }" \
    "$GRAFANA_URL/api/dashboards/import")

if echo "$IMPORT_RESPONSE" | grep -q '"uid"'; then
    DASHBOARD_UID=$(echo "$IMPORT_RESPONSE" | grep -o '"uid":"[^"]*"' | cut -d'"' -f4)
    echo "✓ Dashboard imported successfully!"
    echo ""
    echo "============================================"
    echo "Setup Complete!"
    echo "============================================"
    echo "Dashboard URL: $GRAFANA_URL/d/$DASHBOARD_UID/body-composition-dashboard"
    echo ""
    echo "Login credentials:"
    echo "  Username: admin"
    echo "  Password: admin"
    echo "============================================"
else
    echo "WARNING: Dashboard import may have failed or already exists"
    echo "Response: $IMPORT_RESPONSE"
    echo ""
    echo "You can manually import the dashboard:"
    echo "1. Go to $GRAFANA_URL"
    echo "2. Dashboards → Import"
    echo "3. Upload: weight-dashboard.json"
fi
