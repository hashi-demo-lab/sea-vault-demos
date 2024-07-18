#!/bin/bash
PASSWORD="$1"
SALT="$(openssl rand -base64 3)"
HASH="$(echo -n "${PASSWORD}${SALT}" | openssl dgst -sha1 -binary | base64)"
SSHA="{SSHA}${HASH}${SALT}"
echo "{\"passwordHash\":\"${SSHA}\"}"
