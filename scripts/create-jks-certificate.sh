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

keystore_filepath="$SECRETS_PATH/$service.keystore.jks"
truststore_filepath="$SECRETS_PATH/$service.truststore.jks"
csr_filepath="$SECRETS_PATH/$service.csr"
signed_cert_filepath="$SECRETS_PATH/$service-ca1-signed.crt"
serial_filepath="$SECRETS_PATH/$service.srl"

echo "Creating KeyStore & TrustStore for $service"
# Create keystores
keytool -genkey -noprompt \
  -alias "$service" \
  -dname "CN=$service.test.confluent.io, OU=TEST, O=CONFLUENT, L=PaloAlto, S=Ca, C=US" \
  -keystore "$keystore_filepath" \
  -keyalg RSA \
  -storepass "$password" \
  -keypass "$password"

# Create CSR, sign the key and import back into keystore
keytool -noprompt \
  -keystore "$keystore_filepath" \
  -alias "$service" \
  -certreq \
  -file "$csr_filepath" \
  -storepass "$password" \
  -keypass "$password"

openssl x509 \
  -req \
  -CA "$root_cert_filepath" \
  -CAkey "$root_key_filepath" \
  -CAcreateserial \
  -CAserial "$serial_filepath" \
  -in "$csr_filepath" \
  -out "$signed_cert_filepath" \
  -days 9999 \
  -passin pass:"$password"

keytool -noprompt \
  -keystore "$keystore_filepath" \
  -alias CARoot \
  -import \
  -file "$root_cert_filepath" \
  -storepass "$password" \
  -keypass "$password"

keytool -noprompt \
  -keystore "$keystore_filepath" \
  -alias "$service" \
  -import \
  -file "$signed_cert_filepath" \
  -storepass "$password" \
  -keypass "$password"

# Create truststore and import the CA cert.
keytool -noprompt \
  -keystore "$truststore_filepath" \
  -alias CARoot \
  -import \
  -file "$root_cert_filepath" \
  -storepass "$password" \
  -keypass "$password"

echo "$password" >"$SECRETS_PATH/${service}_sslkey_creds"
echo "$password" >"$SECRETS_PATH/${service}_keystore_creds"
echo "$password" >"$SECRETS_PATH/${service}_truststore_creds"
