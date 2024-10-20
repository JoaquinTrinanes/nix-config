#!/usr/bin/env bash

layout_laravel_sail() {
  layout php

  local bin_dir
  bin_dir="$(direnv_layout_dir)/laravel_sail/bin"

  rm -rf "$bin_dir"

  if [ ! -f "$PWD/vendor/bin/sail" ]; then
    return
  fi

  mkdir -p "$bin_dir"
  local scripts=(
    composer
    # php
    artisan
    tinker
    # pint
    # npm
    # npx
    # yarn
    # pnpm
  )
  for script in "${scripts[@]}"; do
    local file="$bin_dir/$script"
    echo "#!/usr/bin/env bash" >"$file"
    echo "\"$PWD/vendor/bin/sail\" \"$script\" \"\$@\"" >>"$file"
  done

  chmod -R u+x "$bin_dir"
  PATH_add "$bin_dir"
}
