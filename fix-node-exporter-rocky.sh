#!/bin/bash
# Fix Node Exporter on Rocky Linux (SELinux issue)

echo "Fixing Node Exporter permissions and SELinux context..."

# Make sure the binary is executable
sudo chmod +x /usr/local/bin/node_exporter

# Fix SELinux context (this is the key fix for Rocky/RHEL)
sudo restorecon -v /usr/local/bin/node_exporter

# Alternative: set the correct SELinux context explicitly
sudo chcon -t bin_t /usr/local/bin/node_exporter

# Restart the service
sudo systemctl daemon-reload
sudo systemctl restart node_exporter

echo ""
echo "Checking status..."
sudo systemctl status node_exporter --no-pager

echo ""
echo "Testing metrics endpoint..."
curl -s http://localhost:9100/metrics | head -n 5

echo ""
echo "✓ Node Exporter should now be running!"
