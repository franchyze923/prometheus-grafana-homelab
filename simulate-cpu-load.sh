#!/bin/bash
# Simulate CPU load for testing monitoring
# Run this on any server to generate CPU load

echo "This will create CPU load for 60 seconds..."
echo "You should see this spike in Grafana!"
echo ""
echo "Starting CPU load test..."

# Run 4 CPU-intensive processes in parallel (one per core)
# Each runs for 60 seconds then stops
for i in {1..4}; do
    dd if=/dev/zero of=/dev/null &
done

echo "CPU load test running for 60 seconds..."
echo "Check Grafana now! CPU should spike to ~100%"
echo ""
echo "Waiting..."

# Wait 60 seconds
sleep 60

# Kill all the dd processes
killall dd

echo ""
echo "CPU load test complete! CPU should return to normal."
echo "Check Grafana to see the spike!"
