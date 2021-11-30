#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

password=relexsolutions

kcat -b localhost:19092 \
  -X security.protocol=SSL \
  -X ssl.key.location=./scripts/secrets/kcat.key \
  -X ssl.key.password=$password \
  -X ssl.certificate.location=./scripts/secrets/kcat-signed.crt \
  -X ssl.ca.location=./scripts/secrets/root.crt \
  -X ssl.endpoint.identification.algorithm=none \
  -X enable.ssl.certificate.verification=false \
  -L
