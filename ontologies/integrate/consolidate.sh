#!/usr/bin/env bash

BASE_PATH=integrate/
UPDATES_CSV_PATH="consolidation_updates.csv"
TDB2_CONF_PATH="/opt/homebrew/var/fuseki/configuration/hacid-onto-integrate.ttl"

brew services stop fuseki

tail -n +2 $BASE_PATH$UPDATES_CSV_PATH | awk -F "," '{
        if ($2 != "y") {
            system("ls -l '$BASE_PATH'" $1 " | awk '\''{ print $9 }'\''")
        }
    }' | awk -F "," '{
        print("Running " $1 " ...");
        system("tdb2.tdbupdate --tdb '$TDB2_CONF_PATH' --update " $1);
    }'

brew services start fuseki
