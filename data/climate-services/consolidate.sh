#!/usr/bin/env bash

UPDATES_CSV_PATH="consolidation_updates.csv"
TDB2_CONF_PATH="/opt/homebrew/var/fuseki/configuration/hacid-test.ttl"

brew services stop fuseki

tail -n +2 $UPDATES_CSV_PATH | awk -F "," '{
        if ($2 != "y") {
            system("ls -l " $1 " | awk '\''{ print $9 }'\''")
        }
    }' | awk -F "," '{
        print("Running " $1 " ...");
        system("tdb2.tdbupdate --tdb '$TDB2_CONF_PATH' --update " $1);
    }'

brew services start fuseki
