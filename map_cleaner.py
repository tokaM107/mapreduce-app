#!/usr/bin/env python
# -*- coding: utf-8 -*-
import sys
import csv

# Create a CSV reader for standard input
reader = csv.reader(sys.stdin)

for row in reader:
    # Skip empty rows or rows with not enough columns
    if not row or len(row) <= 13:
        continue

    date, tmp = row[1], row[13]

    # Skip invalid temperatures
    if not tmp or tmp.startswith('+9999'):
        continue

    # Convert temperature to float
    try:
        tmp_value = float(tmp.replace(',', '.'))
    except ValueError:
        continue

    # Emit the cleaned row (tab-separated)
    print("\t".join(row))