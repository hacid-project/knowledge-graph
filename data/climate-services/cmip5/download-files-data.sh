#!/usr/bin/env bash

URL_TEMPLATE="https://esgf-ui.ceda.ac.uk/cog/search_files/\(.)/esgf.ceda.ac.uk/"
DOWNLOAD_CMD="curl"
ID_FILE="./ids-sample.csv"
OUTPUT_FILE="./output-test.json"
GET_RESPONSE="jq '.response.docs[]'"

#echo '{' >$OUTPUT_FILE

INPUT_JSON_PATH="data"
OUTPUT_JSON_PATH="data/files"

mkdir -p $OUTPUT_JSON_PATH
for INPUT_JSON in $INPUT_JSON_PATH/*.json; do
    OUTPUT_JSON=$OUTPUT_JSON_PATH/`basename $INPUT_JSON`
    jq '.response.docs[].id | @uri "'$URL_TEMPLATE'"' -r $INPUT_JSON | \
    awk '
        BEGIN{ print("[") }
        {
            if (NR > 1) print (",");
            url = "'$BASE_URL'" $1 "'$SUFFIX'";
            system("'$DOWNLOAD_CMD' " url);
        }
        END{ print("]") }
    ' | jq '[.[].response.docs[]]' >$OUTPUT_JSON
done

# jq <$ID_FILE -Rr @uri | \
# awk '
#     BEGIN{ print("[") }
#     {
#         if (NR > 1) print (",");
#         url = "'$BASE_URL'" $1 "'$SUFFIX'";
#         system("'$DOWNLOAD_CMD' " url);
#     }
#     END{ print("]") }
# ' | jq '[.[].response.docs[]]' >$OUTPUT_FILE

    # print(url)
    # print("'$DOWNLOAD_CMD' " url " >>'$OUTPUT_FILE'")
    # system("'$DOWNLOAD_CMD' " url " >>'$OUTPUT_FILE'")
# for PAGE_NUM in $( seq 0 $LAST_PAGE )
# do
#     echo "Downloading data page $PAGE_NUM..."
#     PAGE_OFFSET=`expr $PAGE_SIZE \* $PAGE_NUM`
#     PAGE_URL="$URL&offset=$PAGE_OFFSET&limit=$PAGE_SIZE"

#     curl $PAGE_URL \
#         -H 'accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7' \
#         -H 'accept-language: en-GB,en;q=0.9,it-IT;q=0.8,it;q=0.7,es-AR;q=0.6,es;q=0.5,en-US;q=0.4,pt;q=0.3,fr;q=0.2' \
#         >"chunks/cordex-$PAGE_NUM.json"
# done

