#!/usr/bin/env python3
import sys
import csv

for line in sys.stdin:
    line = line.strip()
    if not line:
        continue

    reader = csv.reader([line])
    for row in reader:
        try:
            date = row[1]      
            tmp = row[13]      
        except IndexError:
            continue

        
        if tmp == '' or tmp.startswith('+9999'):
            continue

        try:
            tmp_value = float(tmp.replace(',', '.'))
        except ValueError:
            continue

        year = date[:4]  

print(f"{year}\t{tmp_value}")
