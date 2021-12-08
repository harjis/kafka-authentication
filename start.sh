#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

if [[ ! -f "scripts/secrets/root.crt" ]]; then
  DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  cd "$DIR/scripts" && ./create-certs.sh
fi

docker-compose up -d
