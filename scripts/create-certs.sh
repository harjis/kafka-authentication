#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SECRETS_PATH="$DIR/secrets"

# This is needed so that relative path on scripts can be used
cd "$DIR"

root_cert_filepath="$SECRETS_PATH/root.crt"
root_key_filepath="$SECRETS_PATH/root.key"
password=relexsolutions

# Create root.crt & root.key files
echo "Create root certificate"
openssl req \
  -new \
  -x509 \
  -keyout "$root_key_filepath" \
  -out "$root_cert_filepath" \
  -days 365 \
  -subj '/CN=ca1.test.confluent.io/OU=TEST/O=CONFLUENT/L=PaloAlto/S=Ca/C=US' \
  -passin pass:$password \
  -passout pass:$password

for service in kafka; do
  ./create-jks-certificate.sh $service $password "$root_cert_filepath" "$root_key_filepath"
done

./create-pem-certificate.sh kcat $password "$root_cert_filepath" "$root_key_filepath"
