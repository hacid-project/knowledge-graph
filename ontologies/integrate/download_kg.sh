#!/usr/bin/env bash

MAP_FILE_PATH="integrate/graph_names.csv"
GRAPH_STORE_PROTOCOL_EP="http://localhost:3030/hacid-onto-integrate/get"

tail -n +2 $MAP_FILE_PATH | awk -F "," '{
        if ($4 != "y") {
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
        system("wget --header '\''Accept: application/rdf+xml'\'' '\'$GRAPH_STORE_PROTOCOL_EP'" (! $2 ? ("?default'\''  -O " $1) : ("?graph=" $1 "'\''  -O " $2)))
    }
'
