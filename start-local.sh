#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail
readonly repo="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

function main {
  use_nodejs_version "12"

  cd "$repo"
  DATABASE_URL="postgres://possu:possu@localhost:5555/possu" \
  npm start
}

function use_nodejs_version {
  local node_version="$1"

  set +o nounset
  export NVM_DIR="${NVM_DIR:-$HOME/.cache/nvm}"
  source "$repo/nvm.sh"
  nvm install "$node_version"
  nvm use "$node_version"
  set -o nounset
}

main "$@"
