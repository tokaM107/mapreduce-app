#!/bin/bash

# MapReduce Job Runner Script
# This script runs the weather data mapper job on Hadoop

set -e

# Configuration
INPUT_DIR="/weather-data/*.csv"
OUTPUT_DIR="/weather-output"
MAPPER_SCRIPT="/opt/map.py"
STREAMING_JAR="/opt/hadoop/share/hadoop/tools/lib/hadoop-streaming-3.3.6.jar"

echo "=== Starting MapReduce Job ==="
echo "Input: $INPUT_DIR"
echo "Output: $OUTPUT_DIR"
echo "Mapper: $MAPPER_SCRIPT"
echo ""

# Copy mapper script to namenode container
echo "Copying mapper script to namenode..."
docker cp map.py namenode:$MAPPER_SCRIPT
echo "✓ Mapper copied"
echo ""

# Remove existing output directory if it exists
echo "Cleaning up existing output directory..."
docker exec namenode hdfs dfs -rm -r -f $OUTPUT_DIR 2>/dev/null || true
echo "✓ Output directory cleaned"
echo ""

# Run the MapReduce job
echo "Submitting MapReduce job..."
docker exec namenode hadoop jar $STREAMING_JAR \
  -input $INPUT_DIR \
  -output $OUTPUT_DIR \
  -mapper $MAPPER_SCRIPT \
  -file $MAPPER_SCRIPT

# Check if job succeeded
if [ $? -eq 0 ]; then
    echo ""
    echo "=== Job Completed Successfully ==="
    echo ""
    echo "Showing first 20 results:"
    docker exec namenode hdfs dfs -cat $OUTPUT_DIR/part-* | head -20
else
    echo ""
    echo "=== Job Failed ==="
    exit 1
fi
