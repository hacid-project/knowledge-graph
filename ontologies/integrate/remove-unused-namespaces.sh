#!/usr/bin/env bash

MAP_FILE_PATH="integrate/graph_names.csv"
XSLT_PATH="integrate/remove-unused-namespaces.xslt"

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
        owl_file = $2 ? $2 : $1
        system("xsltproc --output " owl_file " '$XSLT_PATH' " owl_file)
    }
'
