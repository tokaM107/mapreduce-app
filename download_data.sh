#!/bin/bash

# Script to download, verify, and decompress NOAA weather data

set -e  # Exit on any error

URL="https://www.ncei.noaa.gov/data/global-hourly/archive/csv/1939.tar.gz"
OUTPUT_FILE="1939.tar.gz"
OUTPUT_DIR=".data/weather"

echo "Downloading NOAA weather data from $URL..."
curl -L -o "$OUTPUT_FILE" "$URL"

if [ $? -ne 0 ]; then
    echo "Error: Download failed!"
    exit 1
fi

echo "Download complete. Checking file integrity..."

# Check if file is a valid gzip file
if ! gzip -t "$OUTPUT_FILE" 2>/dev/null; then
    echo "Error: Downloaded file is corrupted or not a valid gzip file!"
    rm -f "$OUTPUT_FILE"
    exit 1
fi

echo "File integrity check passed."

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

echo "Decompressing file to $OUTPUT_DIR..."
tar -xzf "$OUTPUT_FILE" -C "$OUTPUT_DIR"

if [ $? -ne 0 ]; then
    echo "Error: Decompression failed!"
    exit 1
fi

echo "Decompression complete."
echo "Files extracted to: $OUTPUT_DIR"
echo "Cleaning up archive file..."
rm -f "$OUTPUT_FILE"

echo "Done! Weather data is ready."
