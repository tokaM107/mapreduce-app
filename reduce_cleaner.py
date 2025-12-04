#!/usr/bin/env python
# -*- coding: utf-8 -*-
import sys

for line in sys.stdin:
    line = line.strip()
    if line:
        # Output each cleaned row
        print(line)