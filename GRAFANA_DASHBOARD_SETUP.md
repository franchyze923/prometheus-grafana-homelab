# Grafana Dashboard Setup Guide

## Quick Import Instructions

### Step 1: Access Grafana
1. Open your browser and go to http://localhost:3001
2. Login with:
   - Username: `admin`
   - Password: `admin`
3. Skip or change password when prompted

### Step 2: Add Prometheus Data Source (if not already configured)
1. Click on the **☰** menu (hamburger icon) in the top left
2. Go to **Connections** → **Data sources**
3. Click **Add data source**
4. Select **Prometheus**
5. Configure:
   - **Name**: `prometheus` (important - must be exactly this name)
   - **URL**: `http://prometheus:9090`
6. Click **Save & test** (you should see "Successfully queried the Prometheus API")

### Step 3: Import the Dashboard
1. Click on the **☰** menu in the top left
2. Go to **Dashboards**
3. Click the **New** button dropdown (top right)
4. Select **Import**
5. Click **Upload dashboard JSON file**
6. Select the file: `/home/fran/grafana-prom-homelab/weight-dashboard.json`
7. On the import screen:
   - The dashboard will be named "Body Composition Dashboard"
   - If prompted, select the **prometheus** data source
8. Click **Import**

### Step 4: View Your Dashboard
You should now see your Body Composition Dashboard with these panels:

**Top Row (Current Values):**
- Current Weight gauge (lbs)
- Body Fat % gauge
- Weight Trend graph (30 days)

**Middle Section (Trends):**
- Body Fat % Trend over time
- Muscle Mass Trend over time

**Lower Section:**
- Body Composition Breakdown (stacked area chart showing fat, muscle, bone)
- Body Hydration Trend

**Bottom Row (Stats):**
- Current Muscle Mass
- Current Fat Mass
- Current Hydration
- Current Bone Mass

## Dashboard Features

- **Time Range**: Default shows last 30 days (adjustable in top-right)
- **Auto-refresh**: Refreshes every 30 seconds
- **Tooltips**: Hover over graphs to see exact values
- **Legend Stats**: Shows Last, Min, Max values for each metric

## Customization Tips

### Change Gauge Thresholds
1. Click on a gauge panel title → **Edit**
2. In the right sidebar, go to **Thresholds**
3. Adjust the values to match your goals:
   - Green: Healthy range
   - Yellow: Warning range
   - Red: Needs attention
4. Click **Apply** and **Save dashboard**

### Adjust Time Range
- Use the time picker in the top-right corner
- Quick options: Last 7 days, 30 days, 90 days, etc.
- Or set a custom range

### Add a Goal Line
1. Edit any panel
2. In the query editor, add a new query
3. Use Prometheus syntax: `vector(185)` (for a 185 lb goal)
4. In **Standard options** → **Display name**: "Goal"
5. Apply and save

## Troubleshooting

### "No data" in panels
- Wait a few minutes for Prometheus to collect multiple data points
- Check that the weight exporter is running: `docker ps | grep weight-exporter`
- Verify metrics exist: `curl http://localhost:9090/api/v1/query?query=body_weight_pounds`

### Dashboard won't import
- Make sure the Prometheus data source is named exactly `prometheus`
- Check that the data source is working (Status should be "up" in Status → Targets)

### Graphs look sparse
- The weight exporter fetches new data every 5 minutes
- Your Withings data may only update when you weigh yourself
- Historical data will build up over time

## Manual Panel Creation (Alternative)

If you prefer to build panels manually:

1. Create a new dashboard
2. Add panel
3. Use these queries:
   - Weight: `body_weight_pounds`
   - Body Fat %: `body_fat_percent`
   - Muscle Mass: `body_muscle_mass_pounds`
   - Fat Mass: `body_fat_mass_pounds`
   - Hydration: `body_hydration_pounds`
   - Bone Mass: `body_bone_mass_pounds`

4. Select visualization type:
   - **Gauge**: For current values
   - **Time series**: For trends over time
   - **Stat**: For simple numeric displays

## Next Steps

- Set up alerting for weight goals
- Create annotations for diet/exercise changes
- Add more panels for additional metrics
- Share dashboards with others via snapshot or export
