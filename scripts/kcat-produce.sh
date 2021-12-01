#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SECRETS_PATH="$DIR/secrets"

kcat_key="$SECRETS_PATH/kcat.key"
signed_cert="$SECRETS_PATH/kcat-signed.crt"
root_cert="$SECRETS_PATH/root.crt"
data="$DIR/data.txt"

password=relexsolutions

kcat -b localhost:19092 \
  -X security.protocol=SSL \
  -X ssl.key.location="$kcat_key" \
  -X ssl.key.password=$password \
  -X ssl.certificate.location="$signed_cert" \
  -X ssl.ca.location="$root_cert" \
  -X ssl.endpoint.identification.algorithm=none \
  -X enable.ssl.certificate.verification=false \
  -t test.topic \
  -P -K: -l "$data"
