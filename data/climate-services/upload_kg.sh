#!/usr/bin/env bash

MAP_FILE_PATH="graph_names.csv"
TDB2_LOADER=
TDB2_DB_LOC="/opt/homebrew/var/fuseki/databases/hacid-test"

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
        system("tdb2.tdbloader --loc '$TDB2_DB_LOC' --graph=" $1 " " $2)
    }
'
