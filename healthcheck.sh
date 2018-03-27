#!/bin/bash

echo -n "[$(date +"%d/%m/%Y %H:%M")] application healthcheck" | nc 127.0.0.1 $APP_LISTEN_PORT || exit 1
