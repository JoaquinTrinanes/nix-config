#!/usr/bin/env bash

dot_direnv_outside_project() {
  # shellcheck disable=2317
  direnv_layout_dir() {
    # If direnv_layout_dir is already set, just echo it
    if [ -n "${direnv_layout_dir:-}" ]; then
      echo "$direnv_layout_dir"
      return
    fi

    local hash path
    hash="$(sha1sum - <<<"$PWD" | head -c40)"
    path="${PWD//[^a-zA-Z0-9]/-}"
    echo "${XDG_CACHE_HOME:-$HOME/.cache}/direnv/layouts/${hash}${path}"
  }
}
