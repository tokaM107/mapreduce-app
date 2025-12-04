#!/bin/bash

# MapReduce Cleaner Job Runner Script
# This script runs the data cleaning job on Hadoop

set -e

# Configuration
INPUT_DIR="/weather-data/*.csv"
OUTPUT_DIR="/weather-cleaned"
MAPPER_SCRIPT="/opt/map_cleaner.py"
REDUCER_SCRIPT="/opt/reduce_cleaner.py"
STREAMING_JAR="/opt/hadoop/share/hadoop/tools/lib/hadoop-streaming-3.3.6.jar"

echo "=== Starting MapReduce Cleaner Job ==="
echo "Input: $INPUT_DIR"
echo "Output: $OUTPUT_DIR"
echo "Mapper: $MAPPER_SCRIPT"
echo "Reducer: $REDUCER_SCRIPT"
echo ""

# Copy mapper and reducer scripts to namenode container
echo "Copying mapper script to namenode..."
docker cp map_cleaner.py namenode:$MAPPER_SCRIPT
echo "✓ Mapper copied"

echo "Copying reducer script to namenode..."
docker cp reduce_cleaner.py namenode:$REDUCER_SCRIPT
echo "✓ Reducer copied"
echo ""

# Remove existing output directory if it exists
echo "Cleaning up existing output directory..."
docker exec namenode hdfs dfs -rm -r -f $OUTPUT_DIR 2>/dev/null || true
echo "✓ Output directory cleaned"
echo ""

# Run the MapReduce job
echo "Submitting MapReduce cleaner job..."
docker exec namenode hadoop jar $STREAMING_JAR \
  -input $INPUT_DIR \
  -output $OUTPUT_DIR \
  -mapper $MAPPER_SCRIPT \
  -reducer $REDUCER_SCRIPT \
  -file $MAPPER_SCRIPT \
  -file $REDUCER_SCRIPT

# Check if job succeeded
if [ $? -eq 0 ]; then
    echo ""
    echo "=== Job Completed Successfully ==="
    echo ""
    echo "Showing first 20 cleaned records:"
    docker exec namenode hdfs dfs -cat $OUTPUT_DIR/part-* | head -20
    echo ""
    echo "Total cleaned records:"
    docker exec namenode hdfs dfs -cat $OUTPUT_DIR/part-* | wc -l
else
    echo ""
    echo "=== Job Failed ==="
    exit 1
fi
