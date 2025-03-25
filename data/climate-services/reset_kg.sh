#!/usr/bin/env bash

CONF_FILE_PATH="fuseki-conf.ttl"
FUSEKI_CONF_PATH="/opt/homebrew/var/fuseki/configuration/"
FUSEKI_DB_PATH="/opt/homebrew/var/fuseki/databases/"
DS_NAME="hacid-kg-integrate"

brew services stop fuseki

cp $CONF_FILE_PATH $FUSEKI_CONF_PATH$DS_NAME.ttl
rm -rf "$FUSEKI_DB_PATH$DS_NAME"

brew services start fuseki
