#!/bin/bash
# Install Node Exporter on your homelab server
# Run this script on 192.168.40.112 (or any server you want to monitor)

set -e

echo "Installing Node Exporter..."

# Download and install node_exporter
cd /tmp
wget https://github.com/prometheus/node_exporter/releases/download/v1.8.2/node_exporter-1.8.2.linux-amd64.tar.gz
tar xvfz node_exporter-1.8.2.linux-amd64.tar.gz
sudo mv node_exporter-1.8.2.linux-amd64/node_exporter /usr/local/bin/
rm -rf node_exporter-1.8.2.linux-amd64*

# Create systemd service
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

# Start and enable service
sudo systemctl daemon-reload
sudo systemctl start node_exporter
sudo systemctl enable node_exporter

echo ""
echo "Node Exporter installed successfully!"
echo "Checking status..."
sudo systemctl status node_exporter --no-pager

echo ""
echo "Testing metrics endpoint..."
curl -s http://localhost:9100/metrics | head -n 5

echo ""
echo "✓ Installation complete! Node Exporter is running on port 9100"
