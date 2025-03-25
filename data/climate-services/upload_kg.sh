#!/usr/bin/env bash

MAP_FILE_PATH="graph_names.csv"
TDB2_CONF_PATH="/opt/homebrew/var/fuseki/configuration/hacid-kg-integrate.ttl"

brew services stop fuseki

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
        system("tdb2.tdbloader --tdb '$TDB2_CONF_PATH' --graph=" $1 " " $2)
    }
'

brew services start fuseki
