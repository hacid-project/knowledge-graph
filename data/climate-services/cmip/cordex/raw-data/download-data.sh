#!/usr/bin/env bash

BASE_URL="https://esgf.ceda.ac.uk/esg-search/search/"
FILTER_ITEM_TYPE="Dataset"
FILTER_PROJECTS="CORDEX"
FILTER_EXPERIMENTS="historical%2Crcp26%2Crcp45%2Crcp85"
REQUESTED_FACETS="rcm_name%2Cproject%2Cproduct%2Cdomain%2Cinstitute%2Cdriving_model%2Cexperiment%2Cexperiment_family%2Censemble%2Crcm_version%2Ctime_frequency%2Cvariable%2Cvariable_long_name%2Ccf_standard_name%2Cdata_node"
REQUESTED_FORMAT="application%2Fsolr%2Bjson"
BASE_PARAMS="replica=false&latest=true&format=$REQUESTED_FORMAT"
PARAMS="?$BASE_PARAMS&type=$FILTER_ITEM_TYPE&project=$FILTER_PROJECTS&experiment=$FILTER_EXPERIMENTS&facets=$REQUESTED_FACETS"
URL="$BASE_URL$PARAMS"

# Copied by hand from the API result, it could be automatically read
NUM_ITEMS=162251

PAGE_SIZE=10000
# This is suboptimal cause it gets one page extra if the division is exact
LAST_PAGE=`expr $NUM_ITEMS / $PAGE_SIZE`

for PAGE_NUM in $( seq 0 $LAST_PAGE )
do
    echo "Downloading data page $PAGE_NUM..."
    PAGE_OFFSET=`expr $PAGE_SIZE \* $PAGE_NUM`
    PAGE_URL="$URL&offset=$PAGE_OFFSET&limit=$PAGE_SIZE"

    curl $PAGE_URL \
        -H 'accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7' \
        -H 'accept-language: en-GB,en;q=0.9,it-IT;q=0.8,it;q=0.7,es-AR;q=0.6,es;q=0.5,en-US;q=0.4,pt;q=0.3,fr;q=0.2' \
        >"chunks/cordex-$PAGE_NUM.json"
done

