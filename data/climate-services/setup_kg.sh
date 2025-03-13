#!/usr/bin/env bash

CONF_FILE_PATH="fuseki-conf.ttl"
FUSEKI_CONF_PATH="/opt/homebrew/var/fuseki/configuration/"
DS_NAME="hacid-test"

brew services stop fuseki

cp $CONF_FILE_PATH $FUSEKI_CONF_PATH$DS_NAME.ttl

brew services start fuseki
