#!/usr/bin/env bash

INPUT_JSON_PATH="raw-data/chunks"
OUTPUT_JSON_PATH="data"

for INPUT_JSON in $INPUT_JSON_PATH/*.json; do
    OUTPUT_JSON=$OUTPUT_JSON_PATH/`basename $INPUT_JSON`
    # echo $OUTPUT_JSON
    jq -f 'clean-data.jq' $INPUT_JSON >$OUTPUT_JSON
done

