#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail
readonly repo="$( cd "$( dirname "$0" )" && pwd )"
readonly SCRIPT_NAME="$( basename "$0" )"

function main {
  parse_env_from_symlink_name
  log INFO "Hello, world!"

  require_command "heroku"

  local -r heroku_app="github-actions-to-heroku-${ENV}"
  heroku apps:create $heroku_app || heroku git:remote --app="$heroku_app"

  local -r postgres_name="possukka-$ENV"
  if ! app_has_addon_with_name $heroku_app "$postgres_name"; then
    log INFO "Creating postgresql addon with name '$postgres_name'"
    heroku addons:create heroku-postgresql:hobby-dev \
      --app "$heroku_app" --name "$postgres_name" --wait
  else
    log INFO "postgresql addon with name '$postgres_name' already exists"
  fi

  log INFO "Pushing commit $( git rev-parse HEAD ) to Heroku"
  git push --force "https://blank:${HEROKU_API_KEY}@git.heroku.com/${heroku_app}.git" HEAD:refs/heads/master

  log INFO "Deployment complete"
}

function app_has_addon_with_name {
  local -r app="$1"
  local -r addon="$2"
  heroku addons --app "$app" | grep -q "\($addon\)"
}

function require_command {
  local -r name="$1"

  if [[ ! $( command -v "$name" ) ]]; then
    log ERROR "The command '$name' is required"
    exit 1
  fi
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
