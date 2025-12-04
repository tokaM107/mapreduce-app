#!/bin/bash

# Script to load weather data into HDFS

set -e  # Exit on any error

LOCAL_DATA_DIR=".data/weather"
HDFS_TARGET_DIR="/weather-data"
CONTAINER_NAME="namenode"

echo "Loading weather data from $LOCAL_DATA_DIR to HDFS..."

# Check if local data directory exists
if [ ! -d "$LOCAL_DATA_DIR" ]; then
    echo "Error: Local data directory $LOCAL_DATA_DIR does not exist!"
    echo "Please run ./download_data.sh first to download the data."
    exit 1
fi

# Check if there are any CSV files
if [ -z "$(ls -A $LOCAL_DATA_DIR/*.csv 2>/dev/null)" ]; then
    echo "Error: No CSV files found in $LOCAL_DATA_DIR"
    exit 1
fi

echo "Checking if HDFS directory exists..."
docker exec $CONTAINER_NAME hdfs dfs -test -d $HDFS_TARGET_DIR 2>/dev/null || \
    docker exec $CONTAINER_NAME hdfs dfs -mkdir -p $HDFS_TARGET_DIR

echo "Copying CSV files to HDFS..."
echo "this may take a few minutes, you can monitor progress in the namenode web UI at http://localhost:9870/explorer.html#/weather-data"
# Copy CSV files directly from local to container
docker cp $LOCAL_DATA_DIR/. $CONTAINER_NAME:/tmp/weather-upload/

# Move files from container's /tmp to HDFS
docker exec $CONTAINER_NAME sh -c "hdfs dfs -put -f /tmp/weather-upload/*.csv $HDFS_TARGET_DIR/"

# Clean up temporary files in container
docker exec -u root namenode rm -rf /tmp/weather-upload

echo "Data loaded successfully!"
echo "Verifying files in HDFS..."
docker exec $CONTAINER_NAME hdfs dfs -ls $HDFS_TARGET_DIR | head -20

echo ""
echo "Total files in HDFS:"
docker exec $CONTAINER_NAME hdfs dfs -ls $HDFS_TARGET_DIR | grep -c "\.csv" || echo "0"

echo ""
echo "Done! Weather data is available in HDFS at $HDFS_TARGET_DIR"
