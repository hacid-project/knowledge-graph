#!/usr/bin/env bash

jq -R -s -f 'mapping/climdex.jq' <data/table.md >rdf/climdex.jsonld
jq -f 'mapping/by_sector.jq' <data/by-sector.json >rdf/climdex-sectors.jsonld