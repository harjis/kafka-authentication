#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SECRETS_PATH="$DIR/secrets"

service=$1
password=$2
root_cert_filepath=$3
root_key_filepath=$4

key_filepath="$SECRETS_PATH/$service.key"
csr_filepath="$SECRETS_PATH/$service.csr"
pkcs8_filepath="$SECRETS_PATH/$service-pkcs8.key"
signed_cert_filepath="$SECRETS_PATH/$service-signed.crt"
serial_filepath="$SECRETS_PATH/$service.srl"
service_keypair_filepath="$SECRETS_PATH/$service-keypair.pem"

echo "Creating PEM certificate for $service"

# Create Certificate Signing Request (CSR) kafka.csr
openssl req \
  -newkey rsa:2048 \
  -keyout "$key_filepath" \
  -out "$csr_filepath" \
  -passin pass:"$password" \
  -passout pass:"$password" \
  -subj "/CN=$service.test.confluent.io/OU=TEST/O=CONFLUENT/L=PaloAlto/S=Ca/C=US"

#convert the key to PKCS8, otherwise kafka/java cannot read it
openssl pkcs8 \
  -topk8 \
  -in "$key_filepath" \
  -inform pem \
  -v1 PBE-SHA1-RC4-128 \
  -out "$pkcs8_filepath" \
  -outform pem \
  -passin pass:"$password" \
  -passout pass:"$password"

mv "$pkcs8_filepath" "$key_filepath"

# Sign the CSR with the root CA
openssl x509 -req \
  -CA "$root_cert_filepath" \
  -CAkey "$root_key_filepath" \
  -CAcreateserial \
  -CAserial "$serial_filepath" \
  -in "$csr_filepath" \
  -out "$signed_cert_filepath" \
  -sha256 \
  -days 365 \
  -passin pass:"$password" \
  -extensions v3_req \
  -extfile <(
    cat <<EOF
[req]
distinguished_name = req_distinguished_name
x509_extensions = v3_req
prompt = no
[req_distinguished_name]
CN = $service
[v3_req]
subjectAltName = @alt_names
[alt_names]
DNS.1 = $service
DNS.2 = localhost
EOF
  )

# Combine private key and cert in one file
cat "$key_filepath" "$signed_cert_filepath" >"$service_keypair_filepath"
