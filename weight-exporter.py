#!/usr/bin/env python3
"""
Prometheus exporter for weight dashboard API.
Fetches body composition data and exposes it as Prometheus metrics.
"""
import os
import time
import requests
from prometheus_client import start_http_server, Gauge, Info
from datetime import datetime

# Configuration
WEIGHT_API_URL = os.environ.get("WEIGHT_API_URL", "http://192.168.40.13:5000/api/weights")
EXPORTER_PORT = int(os.environ.get("EXPORTER_PORT", "9101"))
SCRAPE_INTERVAL = int(os.environ.get("SCRAPE_INTERVAL", "300"))  # 5 minutes default

# Define Prometheus metrics
weight_lb = Gauge('body_weight_pounds', 'Current body weight in pounds')
weight_kg = Gauge('body_weight_kilograms', 'Current body weight in kilograms')
fat_percent = Gauge('body_fat_percent', 'Body fat percentage')
fat_mass_lb = Gauge('body_fat_mass_pounds', 'Fat mass in pounds')
fat_mass_kg = Gauge('body_fat_mass_kilograms', 'Fat mass in kilograms')
muscle_mass_lb = Gauge('body_muscle_mass_pounds', 'Muscle mass in pounds')
muscle_mass_kg = Gauge('body_muscle_mass_kilograms', 'Muscle mass in kilograms')
hydration_lb = Gauge('body_hydration_pounds', 'Body hydration in pounds')
hydration_kg = Gauge('body_hydration_kilograms', 'Body hydration in kilograms')
bone_mass_lb = Gauge('body_bone_mass_pounds', 'Bone mass in pounds')
bone_mass_kg = Gauge('body_bone_mass_kilograms', 'Bone mass in kilograms')
fat_free_mass_lb = Gauge('body_fat_free_mass_pounds', 'Fat-free mass in pounds')
fat_free_mass_kg = Gauge('body_fat_free_mass_kilograms', 'Fat-free mass in kilograms')
measurement_timestamp = Gauge('body_measurement_timestamp', 'Unix timestamp of the measurement')
measurement_info = Info('body_measurement', 'Information about the latest body measurement')

def fetch_weight_data():
    """Fetch the latest weight data from the API."""
    try:
        response = requests.get(WEIGHT_API_URL, timeout=10)
        response.raise_for_status()
        data = response.json()

        if not data or len(data) == 0:
            print("No weight data available from API")
            return None

        # Get the most recent measurement (first item in the list)
        latest = data[0]
        return latest

    except requests.exceptions.RequestException as e:
        print(f"Error fetching weight data: {e}")
        return None
    except Exception as e:
        print(f"Unexpected error: {e}")
        return None

def update_metrics():
    """Fetch data and update Prometheus metrics."""
    data = fetch_weight_data()

    if data is None:
        print("No data to update metrics")
        return

    # Update metrics with available data
    if 'weight_lb' in data:
        weight_lb.set(data['weight_lb'])
    if 'weight_kg' in data:
        weight_kg.set(data['weight_kg'])
    if 'fat_percent' in data:
        fat_percent.set(data['fat_percent'])
    if 'fat_mass_lb' in data:
        fat_mass_lb.set(data['fat_mass_lb'])
    if 'fat_mass_kg' in data:
        fat_mass_kg.set(data['fat_mass_kg'])
    if 'muscle_mass_lb' in data:
        muscle_mass_lb.set(data['muscle_mass_lb'])
    if 'muscle_mass_kg' in data:
        muscle_mass_kg.set(data['muscle_mass_kg'])
    if 'hydration_lb' in data:
        hydration_lb.set(data['hydration_lb'])
    if 'hydration_kg' in data:
        hydration_kg.set(data['hydration_kg'])
    if 'bone_mass_lb' in data:
        bone_mass_lb.set(data['bone_mass_lb'])
    if 'bone_mass_kg' in data:
        bone_mass_kg.set(data['bone_mass_kg'])
    if 'fat_free_mass_lb' in data:
        fat_free_mass_lb.set(data['fat_free_mass_lb'])
    if 'fat_free_mass_kg' in data:
        fat_free_mass_kg.set(data['fat_free_mass_kg'])

    # Set timestamp metric
    if 'datetime' in data:
        dt = datetime.fromisoformat(data['datetime'])
        measurement_timestamp.set(dt.timestamp())

    # Set info metric with metadata
    measurement_info.info({
        'date': data.get('date', ''),
        'datetime': data.get('datetime', '')
    })

    print(f"Metrics updated at {datetime.now().isoformat()}")

def main():
    """Main function to start the exporter."""
    print(f"Starting Weight Dashboard Prometheus Exporter on port {EXPORTER_PORT}")
    print(f"Fetching data from: {WEIGHT_API_URL}")
    print(f"Scrape interval: {SCRAPE_INTERVAL} seconds")

    # Start the HTTP server to expose metrics
    start_http_server(EXPORTER_PORT)

    # Initial metrics update
    update_metrics()

    # Continuously update metrics
    while True:
        time.sleep(SCRAPE_INTERVAL)
        update_metrics()

if __name__ == '__main__':
    main()
