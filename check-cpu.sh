#!/bin/bash
# Quick script to check CPU usage on Rocky Linux server
# Run this on 192.168.40.210 to see what's using CPU

echo "=== CPU Usage ==="
top -bn1 | head -20

echo ""
echo "=== Top CPU Processes ==="
ps aux --sort=-%cpu | head -11

echo ""
echo "=== Load Average ==="
uptime

echo ""
echo "=== CPU Info ==="
lscpu | grep -E "^CPU\(s\)|Model name"
