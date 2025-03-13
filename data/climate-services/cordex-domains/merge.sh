#!/usr/bin/env bash

INPUT_REGULAR="raw-data/CORDEX-CMIP5_regular_grids.csv"
INPUT_ROTATED="raw-data/CORDEX-CMIP5_rotated_grids.csv"
OUTPUT="data/CORDEX-CMIP5.csv"

awk <$INPUT_ROTATED '{
    if (NR == 1)
        print "type," $0
    else
        print "rotated," $0
}' >$OUTPUT

awk <$INPUT_REGULAR '{
    if (NR > 1)
        print "regular," $0
}' >>$OUTPUT
