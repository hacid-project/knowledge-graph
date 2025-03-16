#!/usr/bin/env bash

python ws-data-rml.py

cd data-sources/climdex
./map.sh
cd ../..