#!/usr/bin/env bash

INPUT_JSON_PATH="data"
OUTPUT_FILE="ids.csv"

>$OUTPUT_FILE
for INPUT_JSON in $INPUT_JSON_PATH/*.json; do
    jq '.response.docs[].id' $INPUT_JSON | \
    awk '{print substr($1,2,length($1)-2)}' \
    >>$OUTPUT_FILE
done

