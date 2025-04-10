#!/usr/bin/env bash

# Experimental script, has problems with Virtuoso!

MAP_FILE_PATH="graph_names.csv"
TDB2_CONF_PATH="/opt/homebrew/var/fuseki/configuration/hacid-test.ttl"

tail -n +2 $MAP_FILE_PATH | awk -F "," '{
        if ($3 != "y") {
            system("ls -l " $1 " | awk '\''{ print \"" $2 "\", $9 }'\''")
        }
    }' | awk '
    BEGIN{
        OFS=","
    }
    {
            a[$1] = (a[$1] ? a[$1] FS : "") $2
    }
    END{
        for(i in a){
            print i, a[i]
        }
    }
' | awk -F "," '
    {
        print("wget https://semantics.istc.cnr.it/DAV/home/hacid/cs/add-to-graph  --method=PATCH --body-data='\''CLEAR GRAPH <" $1 "> '\'' --http-user='$1' --http-password='$2' --header '\''Content-type: application/sparql-query'\''")
        system("wget https://semantics.istc.cnr.it/DAV/home/hacid/cs/add-to-graph  --method=PATCH --body-data='\''CLEAR GRAPH <" $1 "> '\'' --http-user='$1' --http-password='$2' --header '\''Content-type: application/sparql-query'\''")
    }
'
