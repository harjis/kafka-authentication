#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
SECRETS_PATH="$DIR/secrets"

cd "$SECRETS_PATH" && rm -f ./*.csr ./*.pem ./*.crt ./*.key ./*.properties credentials ./*_creds ./*.jks ./*.srl

