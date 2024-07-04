#!/usr/bin/env bash

use_my_flake() {
  local PROJECT_NAME
  PROJECT_NAME="$(basename "$PWD")"

  if [ $# -ge 1 ]; then
    PROJECT_NAME=$1
    shift
  fi

  FLAKE_PATH="$HOME/.flakes/$PROJECT_NAME"

  if [ -f "$FLAKE_PATH/flake.nix" ]; then
    use flake "$FLAKE_PATH" --impure "$@"
    export FLAKE_PATH
  fi
}
