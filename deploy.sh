#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail
readonly repo="$( cd "$( dirname "$0" )" && pwd )"
readonly SCRIPT_NAME="$( basename "$0" )"

function main {
  parse_env_from_symlink_name
  log INFO "Hello, world!"
}

function log {
  local -r level="$1"
  local -r message="$2"

  local -r timestamp="$( date +"%Y-%m-%d %H:%M:%S" )"
  >&2 echo -e "${timestamp} [${level}] [$SCRIPT_NAME] ${message}"
}

function parse_env_from_symlink_name {
  local -r FILE_NAME=$(basename "$0")
  if echo "${FILE_NAME}" | grep -E -q 'deploy-.{2,4}\.sh'; then
    readonly ENV=$(echo "${FILE_NAME}" | sed -E -e 's|deploy-(.{2,4})\.sh|\1|g')
    log INFO "Deploying to [${ENV}]"
  else
    log ERROR "Don't call this script directly"
    exit 1
  fi
}

main "$@"
